<template>
  <div class="container mt-5 mb-5">
    <div v-if="loading" class="d-flex justify-content-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <template v-else-if="!isEditing || event">
      <h1 class="mb-4">{{ title }}</h1>

      <form @submit.prevent="submitForm">
        <div class="mb-3">
          <label for="title" class="form-label">Nome*</label>
          <input
            id="title"
            v-model="formData.title"
            type="text"
            class="form-control"
            required
          />
          <div v-if="errors.title" class="text-danger mt-1">
            {{ errors.title }}
          </div>
        </div>

        <div class="mb-3">
          <label for="description" class="form-label">Descrição</label>
          <textarea
            id="description"
            v-model="formData.description"
            class="form-control"
            rows="3"
          ></textarea>
        </div>

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
          <div v-if="errors.team_id" class="text-danger mt-1">
            {{ errors.team_id }}
          </div>
        </div>

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
          <div v-if="errors.duration_seconds" class="text-danger mt-1">
            {{ errors.duration_seconds }}
          </div>
        </div>

        <!-- Members Section -->
        <div class="mt-4">
          <h3>Membros do Evento</h3>

          <!-- Add Members Section -->
          <div class="card mb-4">
            <div class="card-header bg-primary text-white">
              Adicionar Membros
            </div>
            <div class="card-body">
              <div v-if="!formData.team_id" class="alert alert-info">
                Selecione um time para gerenciar os membros
              </div>
              <div v-else class="row mb-3">
                <div class="col-12">
                  <div class="mb-2">
                    <input
                      type="text"
                      class="form-control"
                      placeholder="Pesquisar membro por nome..."
                      v-model="searchTerm"
                      @input="filterAvailableMembers"
                    />
                  </div>
                  <select
                    multiple
                    class="form-select"
                    size="5"
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
                </div>
              </div>
            </div>
          </div>

          <!-- Current Members List -->
          <div class="card mb-4">
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
                  <tr v-if="loadingMembers">
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
                        type="button"
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
        </div>

        <div class="d-flex gap-2">
          <button
            type="submit"
            class="btn btn-primary"
            :disabled="
              loading ||
              !formData.title ||
              !formData.team_id ||
              !formData.duration_seconds
            "
          >
            Salvar
          </button>
          <router-link :to="{ name: 'EventsList' }" class="btn btn-secondary">
            Cancelar
          </router-link>
        </div>
      </form>
    </template>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getEvent, createEvent, editEvent } from "@/api/events";
import { getTeams } from "@/api/teams";
import { getMembers } from "@/api/members";

export default {
  name: "EventForm",

  data() {
    return {
      formData: {
        title: "",
        description: "",
        team_id: "",
        duration_seconds: "",
      },
      event: null,
      teams: [],
      isEditing: false,
      eventId: null,
      loading: false,
      errors: {},

      // Members management
      eventMembers: [],
      availableMembers: [],
      allMembers: [],
      filteredAvailableMembers: [],
      searchTerm: "",
      loadingMembers: false,
    };
  },

  computed: {
    title() {
      return this.isEditing
        ? `Editar Evento: ${this.event?.title || ""}`
        : "Novo Evento";
    },
  },

  async mounted() {
    const { id } = this.$route.params;
    if (id) {
      this.isEditing = true;
      this.eventId = id;
      await this.fetchEvent();
    }
    await Promise.all([this.fetchTeams(), this.fetchMembers()]);
  },

  methods: {
    async fetchEvent() {
      await handleRequest({
        request: () => getEvent(this.eventId),
        processOnSuccess: (response) => {
          const record = response.record;
          this.event = record;
          this.formData.title = record.title;
          this.formData.description = record.description || "";
          this.formData.team_id = record.team_id;
          this.formData.duration_seconds = record.duration_seconds;
          this.eventMembers = record.members || [];
        },
        errorMessage: "Erro ao buscar dados do evento",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
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
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },

    async fetchMembers() {
      await handleRequest({
        request: () => getMembers({ all_records: true }),
        processOnSuccess: (response) => {
          this.allMembers = response.records || [];
          this.updateAvailableMembers();
        },
        errorMessage: "Erro ao carregar membros",
        eventBus: this.$eventBus,
      });
    },

    handleTeamChange() {
      if (this.formData.team_id) {
        const membersToRemove = this.eventMembers.filter(
          (member) =>
            !member.teams?.some((team) => team.id === this.formData.team_id)
        );

        if (membersToRemove.length > 0) {
          const memberNames = membersToRemove.map((m) => m.name).join(", ");
          this.$eventBus.emit(
            "displayAlert",
            `Os seguintes membros foram removidos pois não pertencem ao time selecionado: ${memberNames}`
          );
        }

        this.eventMembers = this.eventMembers.filter((member) =>
          member.teams?.some((team) => team.id === this.formData.team_id)
        );
      }

      this.updateAvailableMembers();
    },

    updateAvailableMembers() {
      const eventMemberIds = this.eventMembers.map((m) => m.id);

      // Filter members by team if a team is selected
      let teamMembers = this.allMembers;
      if (this.formData.team_id) {
        teamMembers = this.allMembers.filter((member) =>
          member.teams?.some((team) => team.id === this.formData.team_id)
        );
      }

      // Remove members already in the event
      this.availableMembers = teamMembers.filter(
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

    handleMemberSelection(event) {
      const selectedOptions = Array.from(event.target.selectedOptions);
      const selectedMemberIds = selectedOptions.map((option) =>
        Number(option.value)
      );

      selectedMemberIds.forEach((memberId) => {
        const member = this.allMembers.find((m) => m.id === memberId);
        if (member && !this.eventMembers.some((m) => m.id === member.id)) {
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
      if (!this.formData.duration_seconds) {
        this.errors = {
          duration_seconds: "A duração deve ser selecionada",
        };
        return;
      }

      this.errors = {};

      const eventData = {
        ...this.formData,
        member_ids: this.eventMembers.map((m) => m.id),
      };

      if (this.isEditing) {
        await handleRequest({
          request: () => editEvent(this.eventId, eventData),
          processOnSuccess: () => {
            this.$router.push({ name: "EventsList" });
          },
          successMessage: "Evento salvo com sucesso",
          errorMessage: "Erro ao salvar evento",
          eventBus: this.$eventBus,
          processOnStart: () => {
            this.loading = true;
          },
          processOnFinally: () => {
            this.loading = false;
          },
        });
      } else {
        await handleRequest({
          request: () => createEvent(eventData),
          processOnSuccess: () => {
            this.$router.push({ name: "EventsList" });
          },
          successMessage: "Evento criado com sucesso",
          errorMessage: "Erro ao criar evento",
          eventBus: this.$eventBus,
          processOnStart: () => {
            this.loading = true;
          },
          processOnFinally: () => {
            this.loading = false;
          },
        });
      }
    },
  },
};
</script>

<style scoped>
.form-select[multiple] {
  height: auto;
  min-height: 150px;
}
</style>
