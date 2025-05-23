<template>
  <BaseList
    title="Relatório de Horas"
    search-placeholder="Pesquisar por Nome do Membro"
    :headers="['Nome', 'Horas', 'Eventos', 'Data de Cadastro']"
    :items="members"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
  >
    <template #row="{ item: member }">
      <td>
        <router-link :to="`/members/${member.id}`" class="text-decoration-none">
          {{ member.name }}
        </router-link>
      </td>
      <td>{{ transformSecondsToHoursAndMinutes(member.total_seconds) }}</td>
      <td>{{ member.event_count }}</td>
      <td>{{ formatDate(member.created_at) }}</td>
    </template>
  </BaseList>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getHoursReport } from "@/api/superadmin/reports";
import BaseList from "../common/BaseList.vue";

export default {
  name: "HoursList",
  components: {
    BaseList,
  },
  data() {
    return {
      members: [],
      totalPages: 1,
      isLoading: true,
    };
  },
  methods: {
    async handleFetch(params) {
      await handleRequest({
        request: () => getHoursReport(params),
        processOnSuccess: (response) => {
          this.members = response.records;
          this.totalPages = response.total_pages || 1;
          this.isLoading = false;
        },
        errorMessage: "Erro ao buscar relatório",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },
    transformSecondsToHoursAndMinutes(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);
      return `${hours}h ${minutes}m`;
    },
    formatDate(date) {
      return new Date(date).toLocaleDateString("pt-BR", {
        day: "2-digit",
        month: "2-digit",
        year: "numeric",
      });
    },
  },
};
</script>
