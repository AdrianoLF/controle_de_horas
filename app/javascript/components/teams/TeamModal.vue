<template>
  <BaseModal :show="show" :title="modalTitle" size="xl" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-4">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>

    <div v-else>
      <form @submit.prevent="submitTeamForm">
        <div class="mb-4">
          <label for="team-name" class="form-label">Nome do Time *</label>
          <input
            id="team-name"
            type="text"
            class="form-control"
            v-model="formData.name"
            required
          />
        </div>
      </form>

      <div v-if="isEditing" class="mt-4">
        <hr />
        <h5 class="mb-3">Gerenciar Membros</h5>

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

        <div class="card">
          <div class="card-header bg-primary text-white">Membros Atuais</div>
          <div class="card-body">
            <table class="table">
              <thead>
                <tr>
                  <th scope="col">Nome</th>
                  <th scope="col">Função</th>
                  <th scope="col"></th>
                </tr>
              </thead>
              <tbody>
                <tr v-if="teamMembers.length === 0">
                  <td colspan="3" class="text-center">
                    Este time ainda não possui membros.
                  </td>
                </tr>
                <tr v-else v-for="member in teamMembers" :key="member.id">
                  <td>{{ member.name }}</td>
                  <td class="text-capitalize">
                    {{ getMemberRole(member.id) }}
                  </td>
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
    </div>

    <template #footer>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        @click="submitTeamForm"
        :disabled="loading"
      >
        {{ loading ? "Salvando..." : "Salvar" }}
      </button>
    </template>
  </BaseModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import {
  getTeam,
  createTeam,
  editTeam,
  addMember,
  removeMember,
} from "@/api/teams";
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "TeamModal",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    teamId: {
      type: [String, Number],
      default: null,
    },
    allMembers: {
      type: Array,
      default: () => [],
    },
  },
  data() {
    return {
      formData: { name: "" },
      team: null,
      teamMembers: [],
      memberships: [],
      filteredMembers: [],
      selectedMemberId: "",
      searchQuery: "",
      loading: false,
    };
  },
  computed: {
    isEditing() {
      return !!this.teamId;
    },
    modalTitle() {
      return this.isEditing
        ? `Editar Time: ${this.team?.name || ""}`
        : "Novo Time";
    },
    availableMembers() {
      return this.filteredMembers.filter(
        (member) => !this.teamMembers.some((tm) => tm.id === member.id)
      );
    },
  },
  watch: {
    allMembers: {
      immediate: true,
      handler(newMembers) {
        this.filteredMembers = newMembers;
      },
    },
    show(newVal) {
      if (newVal) {
        this.loadModalData();
      }
    },
  },
  methods: {
    resetForm() {
      this.formData = { name: "" };
      this.team = null;
      this.teamMembers = [];
      this.memberships = [];
      this.selectedMemberId = "";
      this.searchQuery = "";
    },

    async loadModalData() {
      if (this.isEditing) {
        await this.fetchTeamData();
      } else {
        this.resetForm();
      }
    },

    async fetchTeamData() {
      await handleRequest({
        request: () => getTeam(this.teamId),
        processOnSuccess: (response) => {
          this.team = response.record;
          this.formData.name = response.record?.name || "";
          this.teamMembers = response.members || [];
          this.memberships = response.memberships || [];
        },
        errorMessage: "Erro ao buscar dados do time",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },

    async submitTeamForm() {
      if (!this.formData.name.trim()) {
        this.$eventBus.emit("showAlert", {
          type: "error",
          message: "Nome é obrigatório",
        });
        return;
      }

      await handleRequest({
        request: () =>
          this.isEditing
            ? editTeam(this.teamId, this.formData)
            : createTeam(this.formData),
        processOnSuccess: () => {
          this.$emit("saved");
          this.$emit("close");
        },
        successMessage: "Time salvo com sucesso",
        errorMessage: "Erro ao salvar time",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
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

    getMemberRole(memberId) {
      const membership = this.memberships.find((m) => m.member_id === memberId);
      return membership ? membership.role : "member";
    },
  },
};
</script>
