<template>
  <BaseModal :show="show" :title="title" size="xl" @close="$emit('close')">
    <div v-if="loading" class="d-flex justify-content-center py-5">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <form v-else @submit.prevent="submitForm">
      <div class="row">
        <div class="col-md-6">
          <div class="mb-3">
            <label for="title" class="form-label">Nome*</label>
            <input
              id="title"
              v-model="formData.title"
              type="text"
              class="form-control"
              required
            />
          </div>
        </div>
        <div class="col-md-6">
          <div class="mb-3">
            <label for="occurred_at" class="form-label">Data do Evento*</label>
            <input
              id="occurred_at"
              v-model="formData.occurred_at"
              type="date"
              class="form-control"
              required
            />
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6">
          <div class="mb-3">
            <label for="team_id" class="form-label">Time*</label>
            <select
              id="team_id"
              v-model="formData.team_id"
              class="form-control"
              required
              @change="handleTeamChange"
            >
              <option value="" disabled>Selecione um time</option>
              <option v-for="team in teams" :key="team.id" :value="team.id">
                {{ team.name }}
              </option>
            </select>
          </div>
        </div>
        <div class="col-md-6">
          <div class="mb-3">
            <label for="duration" class="form-label">Duração*</label>
            <select
              id="duration"
              v-model="formData.duration_seconds"
              class="form-control"
              required
            >
              <option value="" disabled>Selecione a duração</option>
              <option :value="15 * 60">15 minutos</option>
              <option :value="30 * 60">30 minutos</option>
              <option :value="60 * 60">1 hora</option>
              <option :value="2 * 60 * 60">2 horas</option>
              <option :value="3 * 60 * 60">3 horas</option>
              <option :value="4 * 60 * 60">4 horas</option>
            </select>
          </div>
        </div>
      </div>

      <div class="mb-3">
        <label for="description" class="form-label">Descrição</label>
        <textarea
          id="description"
          v-model="formData.description"
          class="form-control"
          rows="2"
        ></textarea>
      </div>

      <hr class="my-4" />

      <!-- Members Section -->
      <h5 class="mb-3">Gerenciar Membros do Evento</h5>
      <div v-if="!formData.team_id" class="alert alert-info">
        Selecione um time para poder adicionar membros.
      </div>
      <div v-else class="row">
        <!-- Add Members Section -->
        <div class="col-md-6">
          <div class="card">
            <div class="card-header bg-primary text-white">
              Adicionar Membros do Time
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
              Membros no Evento ({{ eventMembers.length }})
            </div>
            <div class="card-body" style="max-height: 320px; overflow-y: auto">
              <table class="table table-sm">
                <tbody>
                  <tr v-if="eventMembers.length === 0">
                    <td class="text-center">Nenhum membro adicionado.</td>
                  </tr>
                  <tr v-else v-for="member in eventMembers" :key="member.id">
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
import { getEvent, createEvent, editEvent } from "@/api/events";
import { getTeams } from "@/api/teams";
import { getMembers } from "@/api/members";
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "EventModal",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    eventId: {
      type: [String, Number],
      default: null,
    },
  },
  data() {
    return {
      formData: {
        title: "",
        description: "",
        team_id: "",
        duration_seconds: "",
        occurred_at: "",
      },
      event: null,
      teams: [],
      loading: false,

      eventMembers: [],
      allTeamMembers: [],
      filteredAvailableMembers: [],
      searchTerm: "",
    };
  },
  computed: {
    isEditing() {
      return !!this.eventId;
    },
    title() {
      return this.isEditing
        ? `Editar Evento: ${this.event?.title || ""}`
        : "Novo Evento";
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
        title: "",
        description: "",
        team_id: "",
        duration_seconds: "",
        occurred_at: "",
      };
      this.event = null;
      this.eventMembers = [];
      this.allTeamMembers = [];
      this.filteredAvailableMembers = [];
      this.searchTerm = "";
    },

    async loadModalData() {
      this.resetForm();
      await this.fetchTeams();
      if (this.isEditing) {
        await this.fetchEvent();
      }
    },

    async fetchEvent() {
      await handleRequest({
        request: () => getEvent(this.eventId),
        processOnSuccess: (response) => {
          const record = response.record;
          this.event = record;
          this.formData = { ...this.formData, ...record };
          if (record.occurred_at) {
            this.formData.occurred_at = record.occurred_at.split("T")[0];
          }
          this.eventMembers = record.members || [];
          if (this.formData.team_id) {
            this.fetchTeamMembers();
          }
        },
        errorMessage: "Erro ao buscar dados do evento",
        eventBus: this.$eventBus,
        processOnStart: () => (this.loading = true),
        processOnFinally: () => (this.loading = false),
      });
    },

    async fetchTeams() {
      await handleRequest({
        request: () => getTeams({ all_records: true }),
        processOnSuccess: (response) => {
          this.teams = response.records;
        },
        errorMessage: "Erro ao carregar times",
        eventBus: this.$eventBus,
      });
    },

    async fetchTeamMembers() {
      if (!this.formData.team_id) return;

      await handleRequest({
        request: () =>
          getMembers({ all_records: true, team_ids: [this.formData.team_id] }),
        processOnSuccess: (response) => {
          this.allTeamMembers = response.records || [];
          this.updateAvailableMembers();
        },
        errorMessage: "Erro ao carregar membros do time",
        eventBus: this.$eventBus,
      });
    },

    handleTeamChange() {
      this.eventMembers = [];
      this.fetchTeamMembers();
    },

    updateAvailableMembers() {
      const eventMemberIds = this.eventMembers.map((m) => m.id);
      this.filteredAvailableMembers = this.allTeamMembers.filter(
        (member) => !eventMemberIds.includes(member.id)
      );
      this.filterAvailableMembers();
    },

    filterAvailableMembers() {
      const term = this.searchTerm.toLowerCase();
      const available = this.allTeamMembers.filter(
        (member) => !this.eventMembers.some((em) => em.id === member.id)
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
        const member = this.allTeamMembers.find((m) => m.id === id);
        if (member) {
          this.eventMembers.push(member);
        }
      });
      event.target.selectedIndex = -1;
      this.updateAvailableMembers();
    },

    removeMember(member) {
      this.eventMembers = this.eventMembers.filter((m) => m.id !== member.id);
      this.updateAvailableMembers();
    },

    async submitForm() {
      const eventData = {
        ...this.formData,
        member_ids: this.eventMembers.map((m) => m.id),
      };

      await handleRequest({
        request: () =>
          this.isEditing
            ? editEvent(this.eventId, eventData)
            : createEvent(eventData),
        processOnSuccess: () => {
          this.$emit("saved");
          this.$emit("close");
        },
        successMessage: `Evento ${
          this.isEditing ? "salvo" : "criado"
        } com sucesso`,
        errorMessage: `Erro ao ${this.isEditing ? "salvar" : "criar"} evento`,
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
