<template>
  <div class="container mt-5">
    <div v-if="loading" class="d-flex justify-content-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <template v-else-if="!isEditing || team">
      <h1 class="mb-4">{{ title }}</h1>
      <form @submit.prevent="submitForm">
        <div class="mb-3">
          <label for="name" class="form-label">Nome</label>
          <input
            type="text"
            class="form-control"
            id="name"
            v-model="formData.name"
            required
          />
        </div>

        <div class="d-flex gap-2">
          <button type="submit" class="btn btn-primary">Salvar</button>
          <router-link to="/teams" class="btn btn-secondary"
            >Cancelar</router-link
          >
        </div>
      </form>
    </template>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getTeam, createTeam, editTeam } from "@/api/teams";

export default {
  name: "TeamForm",
  data() {
    return {
      formData: {
        name: "",
      },
      team: null,
      isEditing: false,
      teamId: null,
      loading: false,
    };
  },

  computed: {
    title() {
      return this.isEditing
        ? `Editar Time: ${this.team?.name || ""}`
        : "Novo Time";
    },
  },

  async mounted() {
    const { id } = this.$route.params;
    if (id) {
      this.isEditing = true;
      this.teamId = id;
      await this.fetchTeam();
    }
  },
  methods: {
    async fetchTeam() {
      await handleRequest({
        request: () => getTeam(this.teamId),
        processOnSuccess: (response) => {
          this.team = response.record;
          this.formData = { name: response.record?.name };
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
    async submitForm() {
      await handleRequest({
        request: () =>
          this.isEditing
            ? editTeam(this.teamId, this.formData)
            : createTeam(this.formData),
        processOnSuccess: () => {
          this.$router.push("/teams");
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
  },
};
</script>
