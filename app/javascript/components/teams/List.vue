<template>
  <BaseList
    title="Lista de Times"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Time"
    new-item-route="/teams/new"
    :headers="['Nome', 'Membros', 'Ações']"
    :items="teams"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
  >
    <template #row="{ item: team }">
      <td>{{ team.name }}</td>
      <td>
        <router-link
          :to="`/teams/${team.id}/members`"
          class="btn btn-info btn-sm"
        >
          {{ team.member_count || 0 }}
        </router-link>
      </td>
      <td class="d-flex gap-2">
        <router-link
          :to="`/teams/edit/${team.id}`"
          class="btn btn-primary btn-sm"
        >
          Editar
        </router-link>
        <button class="btn btn-danger btn-sm" @click="deleteRecord(team.id)">
          Deletar
        </button>
      </td></template
    >
  </BaseList>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getTeams, deleteTeam } from "@/api/teams";
import BaseList from "../common/BaseList.vue";

export default {
  name: "TeamsList",
  components: {
    BaseList,
  },
  data() {
    return {
      teams: [],
      totalPages: 1,
      isLoading: true,
    };
  },
  methods: {
    async handleFetch(params) {
      await handleRequest({
        request: () => getTeams(params),
        processOnSuccess: (response) => {
          this.teams = response.records;
          this.totalPages = response.total_pages || 1;
          this.isLoading = false;
        },
        errorMessage: "Erro ao buscar times",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },
    async deleteRecord(id) {
      if (confirm("Tem certeza que deseja deletar este time?")) {
        await handleRequest({
          request: () => deleteTeam(id),
          processOnSuccess: () => {
            this.handleFetch({ page: 1 });
          },
          successMessage: "Time deletado com sucesso",
          errorMessage: "Erro ao deletar time",
          eventBus: this.$eventBus,
        });
      }
    },
  },
};
</script>
