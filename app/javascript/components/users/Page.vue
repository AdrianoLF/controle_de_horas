<template>
  <div class="container my-4">
    <div class="card shadow">
      <div class="card-header bg-primary text-white">
        <h3 class="mb-0">Meu Perfil</h3>
      </div>
      <div class="card-body">
        <div v-if="loading" class="text-center py-4">
          <div class="spinner-border text-primary" role="status">
            <span class="visually-hidden">Carregando...</span>
          </div>
        </div>

        <div v-else>
          <div v-if="editMode" class="mb-3">
            <form @submit.prevent="updateProfile">
              <div class="mb-3">
                <label for="name" class="form-label">Nome</label>
                <input
                  type="text"
                  class="form-control"
                  id="name"
                  v-model="editedUser.name"
                  placeholder="Seu nome"
                />
              </div>

              <div class="mb-3">
                <label for="email" class="form-label">Email</label>
                <input
                  type="email"
                  class="form-control"
                  id="email"
                  v-model="editedUser.email"
                  placeholder="seu.email@exemplo.com"
                />
              </div>

              <div class="d-flex justify-content-end">
                <button
                  type="button"
                  class="btn btn-secondary me-2"
                  @click="cancelEdit"
                >
                  Cancelar
                </button>
                <button
                  type="submit"
                  class="btn btn-primary"
                  :disabled="saving"
                >
                  <span
                    v-if="saving"
                    class="spinner-border spinner-border-sm me-1"
                    role="status"
                  ></span>
                  Salvar
                </button>
              </div>
            </form>
          </div>

          <div v-else>
            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Nome:</div>
              <div class="col-md-9">
                {{ userProfile.name || "(Não informado)" }}
              </div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Email:</div>
              <div class="col-md-9">{{ userProfile.email }}</div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Administrador do sistema:</div>
              <div class="col-md-9">
                {{ userProfile.super_admin ? "Sim" : "Não" }}
              </div>
            </div>

            <div class="row mb-3">
              <div class="col-md-3 fw-bold">Criado em:</div>
              <div class="col-md-9">
                {{ formatDate(userProfile.created_at) }}
              </div>
            </div>

            <div class="d-flex justify-content-end">
              <button class="btn btn-primary" @click="enableEdit">
                Editar Perfil
              </button>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { getUserProfile, updateUserProfile } from "@/api/users";

export default {
  name: "UserProfile",

  data() {
    return {
      loading: true,
      saving: false,
      editMode: false,
      userProfile: {},
      editedUser: {
        name: "",
        email: "",
      },
    };
  },

  created() {
    this.fetchUserProfile();
  },

  methods: {
    async fetchUserProfile(params) {
      try {
        const response = await getUserProfile(params);
        this.userProfile = response.record;
      } catch (error) {
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao buscar perfil";
        this.$eventBus.emit("displayAlert", message);
      } finally {
        this.loading = false;
      }
    },

    enableEdit() {
      this.editedUser = {
        name: this.userProfile.name,
        email: this.userProfile.email,
      };
      this.editMode = true;
    },

    cancelEdit() {
      this.editMode = false;
      this.editedUser = {
        name: this.userProfile.name,
        email: this.userProfile.email,
      };
    },

    updateProfile() {
      this.saving = true;

      updateUserProfile({ user: this.editedUser })
        .then((response) => {
          this.userProfile = response.record;
          this.editMode = false;
          this.saving = false;

          this.$eventBus.emit("displayAlert", "Perfil atualizado com sucesso!");
        })
        .catch((error) => {
          let message =
            error?.response?.data?.errors?.[0] || "Erro ao atualizar perfil";
          this.$eventBus.emit("displayAlert", message);

          this.saving = false;
        });
    },

    formatDate(dateString) {
      if (!dateString) return "";

      const date = new Date(dateString);
      return new Intl.DateTimeFormat("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
        hour: "2-digit",
        minute: "2-digit",
      }).format(date);
    },
  },
};
</script>
