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
import { handleRequest } from "@/helper/request";
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
      await handleRequest({
        request: () => Promise.all([this.fetchTeam(), this.fetchAllMembers()]),
        processOnSuccess: () => {
          this.isLoading = false;
        },
        errorMessage: "Erro ao carregar dados",
        eventBus: this.$eventBus,
      });
    },
    async fetchTeam() {
      await handleRequest({
        request: () => getTeam(this.teamId),
        processOnSuccess: (response) => {
          this.team = response.record;
          this.teamMembers = response.members || [];
        },
        errorMessage: "Erro ao buscar time",
        eventBus: this.$eventBus,
      });
    },
    async fetchAllMembers() {
      await handleRequest({
        request: () => getMembers({ all_records: true }),
        processOnSuccess: (response) => {
          this.allMembers = response.records || [];
          this.filteredMembers = this.allMembers;
        },
        errorMessage: "Erro ao buscar membros",
        eventBus: this.$eventBus,
      });
    },
    filterMembers() {
      const query = this.searchQuery.toLowerCase();
      this.filteredMembers = this.allMembers.filter((member) =>
        member.name.toLowerCase().includes(query)
      );
    },
    async addMember() {
      if (!this.selectedMemberId) return;

      await handleRequest({
        request: () => addMember(this.teamId, this.selectedMemberId),
        processOnSuccess: (response) => {
          this.team = response.team;
          this.teamMembers = response.members || [];
          this.selectedMemberId = "";
        },
        successMessage: "Membro adicionado com sucesso",
        errorMessage: "Erro ao adicionar membro",
        eventBus: this.$eventBus,
      });
    },
    async removeMember(memberId) {
      if (!confirm("Tem certeza que deseja remover este membro do time?"))
        return;

      await handleRequest({
        request: () => removeMember(this.teamId, memberId),
        processOnSuccess: (response) => {
          this.team = response.team;
          this.teamMembers = response.members || [];
        },
        successMessage: "Membro removido com sucesso",
        errorMessage: "Erro ao remover membro",
        eventBus: this.$eventBus,
      });
    },
  },
};
</script>
