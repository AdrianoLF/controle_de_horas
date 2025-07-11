<template>
  <BaseModal
    :show="isVisible"
    :title="'Criar Novo Usuário'"
    :size="'lg'"
    @close="closeModal"
  >
    <form autocomplete="off" :name="'user-create-form-' + Date.now()">
      <div class="row">
        <div class="col-md-6">
          <div class="mb-3">
            <label for="userName" class="form-label">Nome *</label>
            <input
              id="userName"
              v-model="formData.name"
              type="text"
              class="form-control"
              :class="{ 'is-invalid': errors.name }"
              placeholder="Digite o nome completo"
              autocomplete="off"
              required
            />
            <div v-if="errors.name" class="invalid-feedback">
              {{ errors.name }}
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="mb-3">
            <label for="userEmail" class="form-label">E-mail *</label>
            <input
              id="userEmail"
              v-model="formData.email"
              type="email"
              class="form-control"
              :class="{ 'is-invalid': errors.email }"
              placeholder="Digite o e-mail"
              autocomplete="new-password"
              required
            />
            <div v-if="errors.email" class="invalid-feedback">
              {{ errors.email }}
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6">
          <div class="mb-3">
            <label for="userPassword" class="form-label">Senha *</label>
            <input
              id="userPassword"
              v-model="formData.password"
              type="password"
              class="form-control"
              :class="{ 'is-invalid': errors.password }"
              placeholder="Digite a senha"
              autocomplete="new-password"
              required
            />
            <div v-if="errors.password" class="invalid-feedback">
              {{ errors.password }}
            </div>
          </div>
        </div>

        <div class="col-md-6">
          <div class="mb-3">
            <label for="userPasswordConfirmation" class="form-label"
              >Confirmar Senha *</label
            >
            <input
              id="userPasswordConfirmation"
              v-model="formData.password_confirmation"
              type="password"
              class="form-control"
              :class="{ 'is-invalid': errors.password_confirmation }"
              placeholder="Confirme a senha"
              autocomplete="new-password"
              required
            />
            <div v-if="errors.password_confirmation" class="invalid-feedback">
              {{ errors.password_confirmation }}
            </div>
          </div>
        </div>
      </div>

      <div class="row">
        <div class="col-md-6">
          <div class="form-check mb-3">
            <input
              id="superAdminCheck"
              v-model="formData.super_admin"
              class="form-check-input"
              type="checkbox"
            />
            <label class="form-check-label" for="superAdminCheck">
              Super Administrador
            </label>
          </div>
        </div>

        <div class="col-md-6">
          <div class="form-check mb-3">
            <input
              id="suspendedCheck"
              v-model="formData.suspended"
              class="form-check-input"
              type="checkbox"
            />
            <label class="form-check-label" for="suspendedCheck">
              Usuário Suspenso
            </label>
          </div>
        </div>
      </div>
    </form>

    <template #footer>
      <button type="button" class="btn btn-secondary" @click="closeModal">
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        @click="createUser"
        :disabled="loading"
      >
        <span
          v-if="loading"
          class="spinner-border spinner-border-sm me-2"
          aria-hidden="true"
        ></span>
        Criar Usuário
      </button>
    </template>
  </BaseModal>
</template>

<script>
import BaseModal from "../common/BaseModal.vue";
import { createUser } from "../../api/superadmin/users";
import { handleRequest } from "../../helper/request";

export default {
  name: "UserCreateModal",
  components: {
    BaseModal,
  },
  data() {
    return {
      isVisible: false,
      loading: false,
      formData: {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        super_admin: false,
        suspended: false,
      },
      errors: {},
    };
  },
  methods: {
    show() {
      this.resetForm();
      this.isVisible = true;
    },

    closeModal() {
      this.isVisible = false;
      this.resetForm();
    },

    resetForm() {
      this.formData = {
        name: "",
        email: "",
        password: "",
        password_confirmation: "",
        super_admin: false,
        suspended: false,
      };
      this.errors = {};
      this.loading = false;
    },

    async createUser() {
      this.errors = {};

      await handleRequest({
        request: () => createUser({ ...this.formData }),
        processOnSuccess: (response) => {
          this.$emit("user-created", response.record);
          this.closeModal();
        },
        processOnError: (error) => {
          if (
            error.response &&
            error.response.data &&
            error.response.data.errors
          ) {
            const errors = error.response.data.errors;
            this.errors = this.parseErrors(errors);
          }
        },
        successMessage: "Usuário criado com sucesso!",
        errorMessage: "Erro ao criar usuário",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.loading = true;
        },
        processOnFinally: () => {
          this.loading = false;
        },
      });
    },

    parseErrors(errors) {
      const parsedErrors = {};

      errors.forEach((error) => {
        if (error.includes("Name")) {
          parsedErrors.name = error;
        } else if (error.includes("Email")) {
          parsedErrors.email = error;
        } else if (error.includes("Password confirmation")) {
          parsedErrors.password_confirmation = error;
        } else if (error.includes("Password")) {
          parsedErrors.password = error;
        }
      });

      return parsedErrors;
    },
  },
};
</script>
