<template>
  <div>
    <div class="container">
      <h2 class="mb-4">Bem-vindo ao Sistema</h2>
      <div class="card p-3">
        <div class="alert alert-info">
          <p>Sistema de controle de horas</p>
          <p>Use o menu para navegar entre as opções disponíveis.</p>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";

export default {
  data() {
    return {};
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
  },
};
</script>
<style scoped></style>
