<template>
  <div class="container mt-5">
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

        <div class="mb-3 row">
          <div class="col-md-6">
            <label for="hours" class="form-label">Horas*</label>
            <input
              id="hours"
              v-model.number="hours"
              type="number"
              min="0"
              class="form-control"
              @input="calculateDuration"
              required
            />
          </div>
          <div class="col-md-6">
            <label for="minutes" class="form-label">Minutos*</label>
            <input
              id="minutes"
              v-model.number="minutes"
              type="number"
              min="0"
              max="59"
              class="form-control"
              @input="calculateDuration"
              required
            />
          </div>
          <div v-if="errors.duration_seconds" class="text-danger mt-1 col-12">
            {{ errors.duration_seconds }}
          </div>
        </div>

        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary">Salvar</button>
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

export default {
  name: "EventForm",

  data() {
    return {
      formData: {
        title: "",
        description: "",
        team_id: "",
        duration_seconds: 0,
      },
      event: null,
      teams: [],
      isEditing: false,
      eventId: null,
      loading: false,
      errors: {},
      hours: 0,
      minutes: 0,
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
    await this.fetchTeams();
  },

  methods: {
    calculateDuration() {
      const h = this.hours || 0;
      const m = this.minutes || 0;
      this.formData.duration_seconds = h * 60 * 60 + m * 60;
    },

    parseSeconds(seconds) {
      this.hours = Math.floor(seconds / 3600);
      this.minutes = Math.floor((seconds % 3600) / 60);
    },

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
          this.parseSeconds(record.duration_seconds);
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

    async submitForm() {
      this.calculateDuration();

      if (this.formData.duration_seconds <= 0) {
        this.errors = {
          duration_seconds: "A duração deve ser maior que zero",
        };
        return;
      }

      this.errors = {};

      if (this.isEditing) {
        await handleRequest({
          request: () => editEvent(this.eventId, this.formData),
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
          request: () => createEvent(this.formData),
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
