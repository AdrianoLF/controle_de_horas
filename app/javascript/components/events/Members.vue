<template>
  <div class="container mt-5">
    <div v-if="loading" class="d-flex justify-content-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <template v-else>
      <h1 class="mb-4">
        Membros do Evento: <span class="text-primary">{{ event.title }}</span>
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
              <tr v-if="loadingTable">
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
                    @click="removeMember(member)"
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
    </template>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getEvent } from "@/api/events";
import { getMembers } from "@/api/members";
import { addMemberToEvent, removeMemberFromEvent } from "@/api/events";

export default {
  name: "EventMembers",

  data() {
    return {
      event: {},
      eventMembers: [],
      availableMembers: [],
      filteredAvailableMembers: [],
      searchTerm: "",
      loading: true,
      loadingTable: false,
      selectedMemberId: "",
    };
  },

  async mounted() {
    await this.refreshData();
  },

  methods: {
    async fetchEvent() {
      await handleRequest({
        request: () => getEvent(this.$route.params.id),
        processOnSuccess: (response) => {
          this.event = response.record;
          this.eventMembers = response.record.members || [];
        },
        errorMessage: "Erro ao carregar evento",
        eventBus: this.$eventBus,
      });
    },

    async fetchMembers() {
      await handleRequest({
        request: () => getMembers({ all_records: true }),
        processOnSuccess: (response) => {
          const allMembers = response.records || [];
          this.updateAvailableMembers(allMembers);
        },
        errorMessage: "Erro ao carregar membros",
        eventBus: this.$eventBus,
      });
    },

    updateAvailableMembers(allMembers) {
      const eventMemberIds = this.eventMembers.map((m) => m.id);
      this.availableMembers = allMembers.filter(
        (member) => !eventMemberIds.includes(member.id)
      );
      this.filterAvailableMembers();
    },

    filterAvailableMembers() {
      if (!this.searchTerm) {
        this.filteredAvailableMembers = this.availableMembers;
        return;
      }

      const term = this.searchTerm.toLowerCase();
      this.filteredAvailableMembers = this.availableMembers.filter(
        (member) =>
          member.name.toLowerCase().includes(term) ||
          (member.email && member.email.toLowerCase().includes(term))
      );
    },

    async addSelectedMember() {
      if (!this.selectedMemberId) return;

      await handleRequest({
        request: () =>
          addMemberToEvent(this.$route.params.id, this.selectedMemberId),
        processOnSuccess: async () => {
          this.selectedMemberId = "";
          await this.refreshData();
        },
        successMessage: "Membro adicionado com sucesso",
        errorMessage: "Erro ao adicionar membro",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loadingTable = true;
        },
        processOnFinally: () => {
          this.loadingTable = false;
        },
      });
    },

    async removeMember(member) {
      if (!confirm("Tem certeza que deseja remover este membro do evento?"))
        return;

      await handleRequest({
        request: () => removeMemberFromEvent(this.event.id, member.id),
        processOnSuccess: async () => {
          await this.refreshData();
        },
        successMessage: "Membro removido com sucesso",
        errorMessage: "Erro ao remover membro",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loadingTable = true;
        },
        processOnFinally: () => {
          this.loadingTable = false;
        },
      });
    },

    async refreshData() {
      this.loading = true;
      await this.fetchEvent();
      await this.fetchMembers();
      this.loading = false;
    },
  },
};
</script>
