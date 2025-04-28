<template>
  <div class="container mt-5">
    <h1 class="mb-4">{{ isEditing ? "Editar" : "Novo" }} Membro</h1>
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
        <router-link to="/members" class="btn btn-secondary"
          >Cancelar</router-link
        >
      </div>
    </form>
  </div>
</template>

<script>
import { getMember, createMember, editMember } from "@/api/members";

export default {
  name: "MemberForm",
  data() {
    return {
      formData: {
        name: "",
      },
      isEditing: false,
      memberId: null,
    };
  },
  mounted() {
    const { id } = this.$route.params;
    if (id) {
      this.isEditing = true;
      this.memberId = id;
      this.fetchMember();
    }
  },
  methods: {
    async fetchMember() {
      try {
        const response = await getMember(this.memberId);
        this.formData = response.member;
      } catch (error) {
        let message =
          error?.response?.data?.errors?.[0] ||
          "Erro ao buscar dados do membro";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async submitForm() {
      try {
        if (this.isEditing) {
          await editMember(this.memberId, this.formData);
        } else {
          await createMember(this.formData);
        }
        this.$router.push("/members");
      } catch (error) {
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao salvar membro";
        this.$eventBus.emit("displayAlert", message);
      }
    },
  },
};
</script>
