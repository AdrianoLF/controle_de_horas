<template>
  <div>
    <div class="container">
      <!-- <div class="alert alert-info">
          <p>Sistema de controle de horas</p>
          <p>Use o menu para navegar entre as opções disponíveis.</p>
        </div> -->
      <HoursList class="card-body" />
    </div>
  </div>
</template>

<script>
import { mapGetters } from "vuex";
import HoursList from "./HoursList.vue";

export default {
  components: {
    HoursList,
  },
  data() {
    return {};
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
  },
};
</script>
<style scoped></style>
