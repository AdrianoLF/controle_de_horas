<template>
  <div class="container mt-5">
    <template v-if="!isEditing || member">
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
              <span>{{ team.name }}</span>
              <div class="ms-auto">
                <router-link
                  :to="`/teams/${team.id}/members`"
                  class="btn btn-outline-primary btn-sm me-2"
                >
                  Ver Time
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
      try {
        const { record, teams } = await getMember(this.memberId);
        this.member = record;
        this.memberTeams = teams || [];
        this.formData.name = record?.name || "";
      } catch (e) {
        const msg =
          e?.response?.data?.errors?.[0] || "Erro ao buscar dados do membro";
        this.$eventBus.emit("displayAlert", msg);
      }
    },

    async submitForm() {
      try {
        this.isEditing
          ? await editMember(this.memberId, this.formData)
          : await createMember(this.formData);

        this.$router.push("/members");
      } catch (e) {
        const msg = e?.response?.data?.errors?.[0] || "Erro ao salvar membro";
        this.$eventBus.emit("displayAlert", msg);
      }
    },
  },
};
</script>
