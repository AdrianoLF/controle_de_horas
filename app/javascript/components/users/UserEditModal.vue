<template>
  <BaseModal
    :show="show"
    title="Editar Usuário"
    size="lg"
    @close="$emit('close')"
  >
    <form @submit.prevent="saveUser">
      <div class="row g-3">
        <div class="col-md-6">
          <label for="name" class="form-label">Nome</label>
          <input
            type="text"
            class="form-control"
            id="name"
            v-model="form.name"
            placeholder="Nome do usuário"
          />
        </div>

        <div class="col-md-6">
          <label for="email" class="form-label">Email *</label>
          <input
            type="email"
            class="form-control"
            id="email"
            v-model="form.email"
            placeholder="email@exemplo.com"
            required
          />
        </div>

        <div class="col-md-12">
          <hr class="my-3" />
          <h6 class="mb-3">Permissões e Status</h6>
        </div>

        <div class="col-md-6">
          <div class="form-check form-switch">
            <input
              class="form-check-input"
              type="checkbox"
              id="super_admin"
              v-model="form.super_admin"
            />
            <label class="form-check-label" for="super_admin">
              <strong>Super Administrador</strong>
              <br />
              <small class="text-muted">
                Usuário terá acesso total ao sistema
              </small>
            </label>
          </div>
        </div>

        <div class="col-md-6">
          <div class="form-check form-switch">
            <input
              class="form-check-input"
              type="checkbox"
              id="suspended"
              v-model="form.suspended"
            />
            <label class="form-check-label" for="suspended">
              <strong>Suspender Usuário</strong>
              <br />
              <small class="text-muted"> Usuário não poderá fazer login </small>
            </label>
          </div>
        </div>

        <div class="col-md-12" v-if="showPasswordSection">
          <hr class="my-3" />
          <div class="d-flex justify-content-between align-items-center mb-3">
            <h6 class="mb-0">Alterar Senha</h6>
            <button
              type="button"
              class="btn btn-sm btn-outline-secondary"
              @click="showPasswordSection = false"
            >
              Cancelar alteração
            </button>
          </div>
        </div>

        <div class="col-md-12" v-if="!showPasswordSection">
          <button
            type="button"
            class="btn btn-outline-info btn-sm"
            @click="showPasswordSection = true"
          >
            <i class="fas fa-key me-1"></i>
            Alterar Senha
          </button>
        </div>

        <div class="col-md-6" v-if="showPasswordSection">
          <label for="password" class="form-label">Nova Senha</label>
          <input
            type="password"
            class="form-control"
            id="password"
            v-model="form.password"
            placeholder="Mínimo 6 caracteres"
          />
        </div>

        <div class="col-md-6" v-if="showPasswordSection">
          <label for="password_confirmation" class="form-label"
            >Confirmar Senha</label
          >
          <input
            type="password"
            class="form-control"
            id="password_confirmation"
            v-model="form.password_confirmation"
            placeholder="Repita a nova senha"
          />
        </div>

        <div class="col-md-12" v-if="showPasswordSection && passwordError">
          <div class="alert alert-danger py-2">
            <small>{{ passwordError }}</small>
          </div>
        </div>
      </div>
    </form>

    <template #footer>
      <button
        type="button"
        class="btn btn-secondary"
        @click="$emit('close')"
        :disabled="isLoading"
      >
        Cancelar
      </button>
      <button
        type="button"
        class="btn btn-primary"
        @click="saveUser"
        :disabled="isLoading || !isFormValid"
      >
        <span
          v-if="isLoading"
          class="spinner-border spinner-border-sm me-2"
        ></span>
        {{ isLoading ? "Salvando..." : "Salvar" }}
      </button>
    </template>
  </BaseModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { editUser } from "@/api/superadmin/users";
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "UserEditModal",
  components: {
    BaseModal,
  },
  props: {
    show: {
      type: Boolean,
      default: false,
    },
    user: {
      type: Object,
      default: null,
    },
  },
  emits: ["close", "saved"],
  data() {
    return {
      isLoading: false,
      showPasswordSection: false,
      form: {
        name: "",
        email: "",
        super_admin: false,
        suspended: false,
        password: "",
        password_confirmation: "",
      },
    };
  },
  computed: {
    isFormValid() {
      if (!this.form.email) return false;

      if (this.showPasswordSection) {
        if (!this.form.password || this.form.password.length < 6) return false;
        if (this.form.password !== this.form.password_confirmation)
          return false;
      }

      return true;
    },
    passwordError() {
      if (!this.showPasswordSection) return null;

      if (this.form.password && this.form.password.length < 6) {
        return "A senha deve ter pelo menos 6 caracteres";
      }

      if (
        this.form.password &&
        this.form.password_confirmation &&
        this.form.password !== this.form.password_confirmation
      ) {
        return "As senhas não coincidem";
      }

      return null;
    },
  },
  watch: {
    show(newValue) {
      if (newValue && this.user) {
        this.resetForm();
      }
    },
    user: {
      handler(newUser) {
        if (newUser && this.show) {
          this.resetForm();
        }
      },
      immediate: true,
    },
  },
  methods: {
    resetForm() {
      if (!this.user) return;

      this.form = {
        name: this.user.name || "",
        email: this.user.email || "",
        super_admin: this.user.super_admin || false,
        suspended: this.user.suspended || false,
        password: "",
        password_confirmation: "",
      };
      this.showPasswordSection = false;
    },

    async saveUser() {
      if (!this.isFormValid) return;

      this.isLoading = true;

      const payload = {
        name: this.form.name,
        email: this.form.email,
        super_admin: this.form.super_admin,
        suspended: this.form.suspended,
      };

      if (this.showPasswordSection && this.form.password) {
        payload.user.password = this.form.password;
        payload.user.password_confirmation = this.form.password_confirmation;
      }

      await handleRequest({
        request: () => editUser(this.user.id, payload),
        processOnSuccess: () => {
          this.$emit("saved");
        },
        errorMessage: "Erro ao salvar usuário",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },
  },
};
</script>
