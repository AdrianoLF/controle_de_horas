<template>
  <BaseList
    title="Lista de Times"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Time"
    new-item-route="/teams/new"
    :headers="['#', 'Nome', 'Membros', 'Ações']"
    :items="teams"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
  >
    <template #row="{ item: team }">
      <th scope="row">{{ team.id }}</th>
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
      try {
        const response = await getTeams(params);
        this.teams = response.teams;
        this.totalPages = response.total_pages || 1;
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao buscar times";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async deleteRecord(id) {
      if (confirm("Tem certeza que deseja deletar este time?")) {
        try {
          await deleteTeam(id);
          this.handleFetch({ page: 1 });
        } catch (error) {
          let message =
            error?.response?.data?.errors?.[0] || "Erro ao deletar time";
          this.$eventBus.emit("displayAlert", message);
        }
      }
    },
  },
};
</script>
