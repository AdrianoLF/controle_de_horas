<template>
  <div class="container mt-5">
    <h1 class="mb-4">
      Membros do Time: <span class="text-primary">{{ team.name }}</span>
    </h1>

    <div class="mb-4">
      <router-link to="/teams" class="btn btn-secondary">
        Voltar para Times
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
                v-model="searchQuery"
                @input="filterMembers"
              />
            </div>
            <select v-model="selectedMemberId" class="form-select">
              <option value="">Selecione um membro...</option>
              <option
                v-for="member in availableMembers"
                :key="member.id"
                :value="member.id"
              >
                {{ member.name }}
              </option>
            </select>
          </div>
          <div class="col-md-4">
            <button
              @click="addMember"
              class="btn btn-success w-100"
              :disabled="!selectedMemberId"
            >
              Adicionar Membro
            </button>
          </div>
        </div>
      </div>
    </div>

    <!-- Lista de Membros do Time -->
    <div class="card">
      <div class="card-header bg-primary text-white">Membros Atuais</div>
      <div class="card-body">
        <table class="table">
          <thead>
            <tr>
              <th scope="col">#</th>
              <th scope="col">Nome</th>
              <th scope="col"></th>
            </tr>
          </thead>
          <tbody>
            <tr v-if="isLoading">
              <td colspan="3" class="text-center">Carregando...</td>
            </tr>
            <tr v-else-if="teamMembers.length === 0">
              <td colspan="3" class="text-center">
                Este time ainda não possui membros.
              </td>
            </tr>
            <tr v-else v-for="member in teamMembers" :key="member.id">
              <th scope="row">{{ member.id }}</th>
              <td>{{ member.name }}</td>
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
import { getTeam } from "@/api/teams";
import { getMembers } from "@/api/members";
import { addMember, removeMember } from "@/api/teams";

export default {
  name: "TeamMembers",
  data() {
    return {
      team: {},
      teamMembers: [],
      allMembers: [],
      filteredMembers: [],
      selectedMemberId: "",
      searchQuery: "",
      isLoading: true,
    };
  },
  computed: {
    availableMembers() {
      return this.filteredMembers.filter(
        (member) => !this.teamMembers.some((tm) => tm.id === member.id)
      );
    },
  },
  mounted() {
    const { id } = this.$route.params;
    this.teamId = id;
    this.fetchData();
  },
  methods: {
    async fetchData() {
      this.isLoading = true;
      try {
        await Promise.all([this.fetchTeam(), this.fetchAllMembers()]);
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        const message =
          error?.response?.data?.errors?.[0] || "Erro ao carregar dados";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async fetchTeam() {
      const response = await getTeam(this.teamId);
      this.team = response.record;
      this.teamMembers = response.members || [];
    },
    async fetchAllMembers() {
      const response = await getMembers({ all_members: true });
      this.allMembers = response.records || [];
      this.filteredMembers = this.allMembers;
    },
    filterMembers() {
      const query = this.searchQuery.toLowerCase();
      this.filteredMembers = this.allMembers.filter((member) =>
        member.name.toLowerCase().includes(query)
      );
    },
    async addMember() {
      if (!this.selectedMemberId) return;

      try {
        const response = await addMember(this.teamId, this.selectedMemberId);
        this.team = response.team;
        this.teamMembers = response.members || [];
        this.selectedMemberId = "";
      } catch (error) {
        const message =
          error?.response?.data?.errors?.[0] || "Erro ao adicionar membro";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async removeMember(memberId) {
      if (!confirm("Tem certeza que deseja remover este membro do time?"))
        return;

      try {
        const response = await removeMember(this.teamId, memberId);
        this.team = response.team;
        this.teamMembers = response.members || [];
      } catch (error) {
        const message =
          error?.response?.data?.errors?.[0] || "Erro ao remover membro";
        this.$eventBus.emit("displayAlert", message);
      }
    },
  },
};
</script>
