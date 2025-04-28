<template>
  <div class="container mt-5">
    <h1 class="mb-4">{{ isEditing ? "Editar" : "Novo" }} Time</h1>
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
  </div>
</template>

<script>
import { getTeam, createTeam, editTeam } from "@/api/teams";

export default {
  name: "TeamForm",
  data() {
    return {
      formData: {
        name: "",
      },
      isEditing: false,
      teamId: null,
    };
  },
  mounted() {
    const { id } = this.$route.params;
    if (id) {
      this.isEditing = true;
      this.teamId = id;
      this.fetchTeam();
    }
  },
  methods: {
    async fetchTeam() {
      try {
        const response = await getTeam(this.teamId);
        this.formData = { name: response.team.name };
      } catch (error) {
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao buscar dados do time";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async submitForm() {
      try {
        if (this.isEditing) {
          await editTeam(this.teamId, this.formData);
        } else {
          await createTeam(this.formData);
        }
        this.$router.push("/teams");
      } catch (error) {
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao salvar time";
        this.$eventBus.emit("displayAlert", message);
      }
    },
  },
};
</script>
