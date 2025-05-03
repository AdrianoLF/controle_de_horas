<template>
  <div class="container mt-5">
    <h1 class="mb-4">{{ isEditing ? "Editar" : "Novo" }} Evento</h1>

    <form @submit.prevent="saveEvent">
      <div class="mb-3">
        <label for="title" class="form-label">Nome*</label>
        <input
          id="title"
          v-model="form.title"
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
          v-model="form.description"
          class="form-control"
          rows="3"
        ></textarea>
      </div>

      <div class="mb-3">
        <label for="team_id" class="form-label">Time*</label>
        <select
          id="team_id"
          v-model="form.team_id"
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
        <button type="submit" class="btn btn-primary" :disabled="loading">
          {{ loading ? "Salvando..." : "Salvar" }}
        </button>
        <router-link :to="{ name: 'EventsList' }" class="btn btn-secondary">
          Cancelar
        </router-link>
      </div>
    </form>
  </div>
</template>

<script>
import { ref, reactive, computed, onMounted } from "vue";
import { useRouter, useRoute } from "vue-router";
import { getEvent, createEvent, editEvent } from "@/api/events";
import { getTeams } from "@/api/teams";

export default {
  props: {
    id: {
      type: String,
      default: null,
    },
  },

  setup(props) {
    const router = useRouter();
    const loading = ref(false);
    const teams = ref([]);
    const errors = ref({});
    const hours = ref(0);
    const minutes = ref(0);

    const form = reactive({
      title: "",
      description: "",
      team_id: "",
      duration_seconds: 0,
    });

    const isEditing = computed(() => !!props.id);

    const calculateDuration = () => {
      const h = hours.value || 0;
      const m = minutes.value || 0;
      form.duration_seconds = h * 60 * 60 + m * 60;
    };

    const parseSeconds = (seconds) => {
      hours.value = Math.floor(seconds / 3600);
      minutes.value = Math.floor((seconds % 3600) / 60);
    };

    const fetchEvent = async () => {
      try {
        if (!props.id) return;

        loading.value = true;
        const response = await getEvent(props.id);
        const event = response.data.event;

        form.title = event.title;
        form.description = event.description || "";
        form.team_id = event.team_id;
        form.duration_seconds = event.duration_seconds;

        parseSeconds(event.duration_seconds);
      } catch (error) {
        console.error("Erro ao carregar evento:", error);
      } finally {
        loading.value = false;
      }
    };

    const fetchTeams = async () => {
      try {
        const response = await getTeams({ all_teams: true });
        teams.value = response.teams;
      } catch (error) {
        console.error("Erro ao carregar times:", error);
      }
    };

    const saveEvent = async () => {
      try {
        calculateDuration();

        if (form.duration_seconds <= 0) {
          errors.value = {
            duration_seconds: "A duração deve ser maior que zero",
          };
          return;
        }

        loading.value = true;
        errors.value = {};

        if (isEditing.value) {
          await editEvent(props.id, form);
        } else {
          await createEvent(form);
        }

        router.push({ name: "EventsList" });
      } catch (error) {
        console.error("Erro ao salvar evento:", error);
        if (error.response?.data?.errors) {
          errors.value = error.response.data.errors.reduce((acc, error) => {
            const field = error.toLowerCase().split(" ")[0];
            acc[field] = error;
            return acc;
          }, {});
        }
      } finally {
        loading.value = false;
      }
    };

    onMounted(() => {
      fetchEvent();
      fetchTeams();
    });

    return {
      form,
      teams,
      loading,
      errors,
      isEditing,
      hours,
      minutes,
      calculateDuration,
      saveEvent,
    };
  },
};
</script>
