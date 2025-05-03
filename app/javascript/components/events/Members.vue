<template>
  <div class="container mt-5">
    <h1 class="mb-4">
      Membros do Evento: <span class="text-primary">{{ event.name }}</span>
    </h1>

    <div class="mb-4">
      <router-link to="/events" class="btn btn-secondary">
        Voltar para Eventos
      </router-link>
    </div>

    <!-- Adicionar Membros -->
    <div class="card mb-4">
      <div class="card-header bg-primary text-white">Adicionar Membros</div>
      <div class="card-body">
        <div class="row mb-3">
          <div class="col-md-8">
            <div class="mb-2">
              <input
                type="text"
                class="form-control"
                placeholder="Pesquisar membro por nome..."
                v-model="searchTerm"
                @input="filterAvailableMembers"
              />
            </div>
            <select v-model="selectedMemberId" class="form-select">
              <option value="">Selecione um membro...</option>
              <option
                v-for="member in filteredAvailableMembers"
                :key="member.id"
                :value="member.id"
              >
                {{ member.name }}
              </option>
            </select>
          </div>
          <div class="col-md-4">
            <button
              @click="addSelectedMember"
              class="btn btn-success w-100"
              :disabled="!selectedMemberId"
            >
              Adicionar Membro
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Membros do Evento -->
    <div class="card">
      <div class="card-header bg-primary text-white">Membros Atuais</div>
      <div class="card-body">
        <table class="table">
          <thead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">Nome</th>
              <th scope="col">Email</th>
              <th scope="col"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="loading">
              <td colspan="4" class="text-center">Carregando...</td>
            </tr>
            <tr v-else-if="eventMembers.length === 0">
              <td colspan="4" class="text-center">
                Este evento ainda não possui membros.
              </td>
            </tr>
            <tr v-else v-for="member in eventMembers" :key="member.id">
              <th scope="row">{{ member.id }}</th>
              <td>{{ member.name }}</td>
              <td>{{ member.email }}</td>
              <td>
                <button
                  @click="removeMember(member.id)"
                  class="btn btn-danger btn-sm"
                >
                  Remover
                </button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, onMounted } from "vue";
import { getEvent } from "@/api/events";
import { getMembers } from "@/api/members";
import { addMemberToEvent, removeMemberFromEvent } from "@/api/events";

export default {
  props: {
    id: {
      type: String,
      required: true,
    },
  },

  setup(props) {
    const event = ref({});
    const eventMembers = ref([]);
    const availableMembers = ref([]);
    const filteredAvailableMembers = ref([]);
    const searchTerm = ref("");
    const loading = ref(true);
    const selectedMemberId = ref("");

    const fetchEvent = async () => {
      try {
        const response = await getEvent(props.id);
        event.value = response.data.event;
        eventMembers.value = response.members || [];
      } catch (error) {
        console.error("Erro ao carregar evento:", error);
      }
    };

    const fetchMembers = async () => {
      try {
        const response = await getMembers({ all_members: true });
        const allMembers = response.members || [];

        updateAvailableMembers(allMembers);
      } catch (error) {
        console.error("Erro ao carregar membros:", error);
      } finally {
        loading.value = false;
      }
    };

    const updateAvailableMembers = (allMembers) => {
      const eventMemberIds = eventMembers.value.map((m) => m.id);
      availableMembers.value = allMembers.filter(
        (member) => !eventMemberIds.includes(member.id)
      );
      filterAvailableMembers();
    };

    const filterAvailableMembers = () => {
      if (!searchTerm.value) {
        filteredAvailableMembers.value = availableMembers.value;
        return;
      }

      const term = searchTerm.value.toLowerCase();
      filteredAvailableMembers.value = availableMembers.value.filter(
        (member) =>
          member.name.toLowerCase().includes(term) ||
          member.email.toLowerCase().includes(term)
      );
    };

    const addSelectedMember = async () => {
      if (!selectedMemberId.value) return;

      try {
        await addMemberToEvent(props.id, selectedMemberId.value);
        selectedMemberId.value = "";
        await refreshData();
      } catch (error) {
        console.error("Erro ao adicionar membro:", error);
      }
    };

    const addMember = async (memberId) => {
      try {
        await addMemberToEvent(props.id, memberId);
        await refreshData();
      } catch (error) {
        console.error("Erro ao adicionar membro:", error);
      }
    };

    const removeMember = async (memberId) => {
      if (!confirm("Tem certeza que deseja remover este membro do evento?"))
        return;

      try {
        const member = eventMembers.value.find((m) => m.id === memberId);
        if (member && member.event_assignment_id) {
          await removeMemberFromEvent(member.event_assignment_id);
          await refreshData();
        }
      } catch (error) {
        console.error("Erro ao remover membro:", error);
      }
    };

    const refreshData = async () => {
      loading.value = true;
      await fetchEvent();
      await fetchMembers();
    };

    onMounted(async () => {
      await fetchEvent();
      await fetchMembers();
    });

    return {
      event,
      eventMembers,
      availableMembers,
      filteredAvailableMembers,
      searchTerm,
      loading,
      selectedMemberId,
      addMember,
      addSelectedMember,
      removeMember,
      filterAvailableMembers,
    };
  },
};
</script>
