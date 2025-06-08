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
        <div class="mb-3 d-flex flex-column gap-2">
          <div>
            <label for="name">Nome</label>
            <input
              id="name"
              type="text"
              class="form-control"
              v-model="formData.name"
              required
            />
          </div>
          <div>
            <label for="pix_key">Chave PIX</label>
            <input
              id="pix_key"
              type="text"
              class="form-control"
              v-model="formData.pix_key"
            />
          </div>
          <div class="d-flex gap-2">
            <button class="btn btn-primary" type="submit">Salvar</button>
            <router-link to="/members" class="btn btn-secondary"
              >Cancelar</router-link
            >
          </div>
        </div>

        <hr class="my-4" />

        <div class="mb-4">
          <div class="card">
            <div class="card-header bg-primary text-white">Times do Membro</div>
            <div class="card-body">
              <table class="table">
                <thead>
                  <tr>
                    <th scope="col">Time</th>
                    <th scope="col">Função</th>
                    <th scope="col"></th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-if="loading">
                    <td colspan="3" class="text-center">Carregando...</td>
                  </tr>
                  <tr v-else-if="!memberships || memberships.length === 0">
                    <td colspan="3" class="text-center">
                      Este membro não pertence a nenhum time.
                    </td>
                  </tr>
                  <tr
                    v-else
                    v-for="membership in memberships"
                    :key="membership.id"
                  >
                    <td>
                      <router-link
                        :to="`/teams/${membership.team.id}/members`"
                        class="text-decoration-none"
                      >
                        {{ membership.team.name }}
                      </router-link>
                    </td>
                    <td class="text-capitalize">{{ membership.role }}</td>
                    <td>
                      <button
                        type="button"
                        @click.prevent="removeMembership(membership.team_id)"
                        class="btn btn-danger btn-sm"
                      >
                        Remover
                      </button>
                    </td>
                  </tr>
                </tbody>
              </table>

              <router-link
                v-if="isEditing"
                to="/teams"
                class="btn btn-success btn-sm mt-2"
              >
                Adicionar a Novo Time
              </router-link>
            </div>
          </div>
        </div>
      </form>
    </template>
  </div>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getMember, createMember, editMember } from "@/api/members";
import { removeMember } from "@/api/teams";

export default {
  name: "MemberForm",

  data() {
    return {
      formData: { name: "", pix_key: "" },
      member: null,
      memberships: [],
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
          this.formData.name = response.record?.name || "";
          this.formData.pix_key = response.record?.pix_key || "";
          this.memberships = response.memberships.map((membership) => ({
            ...membership,
            team: response.teams.find((team) => team.id === membership.team_id),
          }));
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
    async removeMembership(teamId) {
      if (!confirm("Tem certeza que deseja remover este membro do time?"))
        return;

      await handleRequest({
        request: () => removeMember(teamId, this.memberId),
        processOnSuccess: () => {
          this.memberships = this.memberships.filter(
            (m) => m.team_id !== teamId
          );
        },
        successMessage: "Membro removido do time com sucesso",
        errorMessage: "Erro ao remover membro do time",
        eventBus: this.$eventBus,
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
