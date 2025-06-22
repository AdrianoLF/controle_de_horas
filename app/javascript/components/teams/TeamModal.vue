<template>
  <BaseModal :show="show" :title="modalTitle" size="xl" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <form v-else @submit.prevent="submitForm">
      <div class="mb-3">
        <label for="title" class="form-label">Nome*</label>
        <input
          id="title"
          v-model="formData.name"
          type="text"
          class="form-control"
          required
        />
      </div>

      <hr class="my-4" />

      <h5 class="mb-3">Gerenciar Membros do Time</h5>
      <div class="row">
        <!-- Add Members Section -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header bg-primary text-white">
              Adicionar Membros
            </div>
            <div class="card-body">
              <input
                type="text"
                class="form-control mb-2"
                placeholder="Pesquisar membro..."
                v-model="searchTerm"
                @input="filterAvailableMembers"
              />
              <select
                multiple
                class="form-select"
                size="8"
                @change="handleMemberSelection($event)"
              >
                <option
                  v-for="member in filteredAvailableMembers"
                  :key="member.id"
                  :value="member.id"
                >
                  {{ member.name }}
                </option>
              </select>
              <small class="form-text text-muted">
                Segure Ctrl/Cmd para selecionar múltiplos.
              </small>
            </div>
          </div>
        </div>

        <!-- Current Members List -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header bg-primary text-white">
              Membros no Time ({{ teamMembers.length }})
            </div>
            <div class="card-body" style="max-height: 320px; overflow-y: auto">
              <table class="table table-sm">
                <tbody>
                  <tr v-if="teamMembers.length === 0">
                    <td class="text-center">Nenhum membro adicionado.</td>
                  </tr>
                  <tr v-else v-for="member in teamMembers" :key="member.id">
                    <td>{{ member.name }}</td>
                    <td class="text-end">
                      <button
                        type="button"
                        @click="removeMember(member)"
                        class="btn btn-danger btn-sm"
                      >
                        &times;
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>
            </div>
          </div>
        </div>
      </div>
    </form>

    <template #footer>
      <button type="button" class="btn btn-secondary" @click="$emit('close')">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        @click="submitForm"
        :disabled="loading"
      >
        {{ loading ? "Salvando..." : "Salvar" }}
      </button>
    </template>
  </BaseModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getTeam, createTeam, editTeam } from "@/api/teams";
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
      formData: {
        name: "",
      },
      team: null,
      loading: false,

      teamMembers: [],
      filteredAvailableMembers: [],
      searchTerm: "",
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
  },
  watch: {
    show(newVal) {
      if (newVal) {
        this.loadModalData();
      } else {
        this.resetForm();
      }
    },
  },
  methods: {
    resetForm() {
      this.formData = {
        name: "",
      };
      this.team = null;
      this.teamMembers = [];
      this.filteredAvailableMembers = [];
      this.searchTerm = "";
    },

    async loadModalData() {
      this.resetForm();
      if (this.isEditing) {
        await this.fetchTeam();
      } else {
        this.updateAvailableMembers();
      }
    },

    async fetchTeam() {
      await handleRequest({
        request: () => getTeam(this.teamId),
        processOnSuccess: (response) => {
          const record = response.record;
          this.team = record;
          this.formData = { ...this.formData, ...record };
          this.teamMembers = response.members || [];
          this.updateAvailableMembers();
        },
        errorMessage: "Erro ao buscar dados do time",
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },

    updateAvailableMembers() {
      const teamMemberIds = this.teamMembers.map((m) => m.id);
      this.filteredAvailableMembers = this.allMembers.filter(
        (member) => !teamMemberIds.includes(member.id)
      );
      this.filterAvailableMembers();
    },

    filterAvailableMembers() {
      const term = this.searchTerm.toLowerCase();
      const available = this.allMembers.filter(
        (member) => !this.teamMembers.some((em) => em.id === member.id)
      );

      if (!term) {
        this.filteredAvailableMembers = available;
        return;
      }

      this.filteredAvailableMembers = available.filter((member) =>
        member.name.toLowerCase().includes(term)
      );
    },

    handleMemberSelection(event) {
      const selectedIds = Array.from(event.target.selectedOptions, (option) =>
        Number(option.value)
      );
      selectedIds.forEach((id) => {
        const member = this.allMembers.find((m) => m.id === id);
        if (member) {
          this.teamMembers.push(member);
        }
      });
      event.target.selectedIndex = -1;
      this.updateAvailableMembers();
    },

    removeMember(member) {
      this.teamMembers = this.teamMembers.filter((m) => m.id !== member.id);
      this.updateAvailableMembers();
    },

    async submitForm() {
      const teamData = {
        ...this.formData,
        member_ids: this.teamMembers.map((m) => m.id),
      };

      await handleRequest({
        request: () =>
          this.isEditing
            ? editTeam(this.teamId, teamData)
            : createTeam(teamData),
        processOnSuccess: (response) => {
          this.$emit("saved", response.record);
          this.$emit("close");
        },
        successMessage: `Time ${
          this.isEditing ? "salvo" : "criado"
        } com sucesso`,
        errorMessage: `Erro ao ${this.isEditing ? "salvar" : "criar"} time`,
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },
  },
};
</script>

<style scoped>
.form-select[multiple] {
  height: auto;
  min-height: 220px;
}
</style>
