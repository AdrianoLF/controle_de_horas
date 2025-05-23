<template>
  <div class="container mt-5">
    <div v-if="loading" class="d-flex justify-content-center">
      <div class="spinner-border text-primary" role="status">
        <span class="visually-hidden">Carregando...</span>
      </div>
    </div>
    <template v-else-if="!isEditing || member">
      <h1 class="mb-4">{{ title }}</h1>

      <form @submit.prevent="submitForm">
        <div class="mb-3">
          <label for="name" class="form-label">Nome</label>
          <input
            id="name"
            type="text"
            class="form-control"
            v-model="formData.name"
            required
          />
        </div>

        <div class="mb-4">
          <h5>Times</h5>
          <div v-if="memberTeams && memberTeams.length > 0">
            <div
              v-for="team in memberTeams"
              :key="team.id"
              class="d-flex align-items-center mb-2 p-2 border rounded"
            >
              <div class="ms-auto">
                <router-link
                  :to="`/teams/${team.id}/members`"
                  class="btn btn-outline-primary btn-sm me-2"
                >
                  <span>{{ team.name }}</span>
                </router-link>
              </div>
            </div>
          </div>
          <div v-else class="alert alert-info">
            Este membro não pertence a nenhum time
          </div>

          <router-link
            v-if="isEditing"
            to="/teams"
            class="btn btn-outline-success btn-sm mt-2"
          >
            Adicionar a Novo Time
          </router-link>
        </div>

        <div class="d-flex gap-2">
          <button class="btn btn-primary" type="submit">Salvar</button>
          <router-link to="/members" class="btn btn-secondary"
            >Cancelar</router-link
          >
        </div>
      </form>
    </template>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getMember, createMember, editMember } from "@/api/members";

export default {
  name: "MemberForm",

  data() {
    return {
      formData: { name: "" },
      member: null,
      memberTeams: [],
      isEditing: false,
      memberId: null,
      loading: false,
    };
  },

  computed: {
    title() {
      return this.isEditing
        ? `Editar Membro: ${this.member?.name || ""}`
        : "Novo Membro";
    },
  },

  async mounted() {
    const { id } = this.$route.params;
    if (id) {
      this.isEditing = true;
      this.memberId = id;
      await this.fetchMember();
    }
  },

  methods: {
    async fetchMember() {
      await handleRequest({
        request: () => getMember(this.memberId),
        processOnSuccess: (response) => {
          this.member = response.record;
          this.memberTeams = response.record.teams || [];
          this.formData.name = response.record?.name || "";
        },
        errorMessage: "Erro ao buscar dados do membro",
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
            ? editMember(this.memberId, this.formData)
            : createMember(this.formData),
        processOnSuccess: () => {
          this.$router.push("/members");
        },
        successMessage: "Membro salvo com sucesso",
        errorMessage: "Erro ao salvar membro",
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
