<template>
  <BaseModal
    :show="show"
    title="Senha Resetada com Sucesso"
    size="md"
    @close="$emit('close')"
    :show-confirm="false"
    :show-cancel="false"
  >
    <div class="text-center">
      <div class="mb-4">
        <i class="fas fa-check-circle text-success" style="font-size: 3rem"></i>
      </div>

      <h5 class="mb-3">Nova senha gerada!</h5>

      <div class="alert alert-info">
        <p class="mb-2">
          <strong>Usuário:</strong> {{ user?.name || user?.email }}
        </p>
        <p class="mb-2"><strong>Email:</strong> {{ user?.email }}</p>
      </div>

      <div class="mb-4">
        <label class="form-label fw-bold">Nova Senha Temporária:</label>
        <div class="input-group">
          <input
            :type="showPassword ? 'text' : 'password'"
            class="form-control text-center fw-bold"
            :value="newPassword"
            readonly
            style="letter-spacing: 2px; font-size: 1.1rem"
          />
          <button
            class="btn btn-outline-secondary"
            type="button"
            @click="showPassword = !showPassword"
          >
            <i :class="showPassword ? 'fas fa-eye-slash' : 'fas fa-eye'"></i>
          </button>
          <button
            class="btn btn-outline-primary"
            type="button"
            @click="copyToClipboard"
          >
            <i class="fas fa-copy"></i>
          </button>
        </div>
      </div>

      <div class="alert alert-warning">
        <small>
          <i class="fas fa-exclamation-triangle me-2"></i>
          <strong>Importante:</strong> Anote ou copie esta senha. O usuário
          deverá alterar a senha no primeiro login.
        </small>
      </div>

      <button class="btn btn-primary btn-lg" @click="$emit('close')">
        <i class="fas fa-check me-2"></i>
        Entendi
      </button>
    </div>
  </BaseModal>
</template>

<script>
import BaseModal from "../common/BaseModal.vue";

export default {
  name: "PasswordResetModal",
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
    newPassword: {
      type: String,
      default: "",
    },
  },
  emits: ["close"],
  data() {
    return {
      showPassword: false,
    };
  },
  watch: {
    show(newValue) {
      if (newValue) {
        this.showPassword = false;
      }
    },
  },
  methods: {
    async copyToClipboard() {
      try {
        await navigator.clipboard.writeText(this.newPassword);
        this.$eventBus.showAlert(
          "Senha copiada para a área de transferência!",
          "success"
        );
      } catch (err) {
        console.error("Erro ao copiar:", err);
        this.$eventBus.showAlert("Erro ao copiar senha", "error");
      }
    },
  },
};
</script>

<style scoped>
.input-group input[readonly] {
  background-color: #f8f9fa;
  border-color: #007bff;
}
</style>
