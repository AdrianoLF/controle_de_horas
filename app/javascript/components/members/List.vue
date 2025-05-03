<template>
  <BaseList
    title="Lista de Membros"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Membro"
    new-item-route="/members/new"
    :headers="['Nome', 'Times', 'Ações']"
    :items="members"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
  >
    <template #row="{ item: member }">
      <td>{{ member.name }}</td>
      <td>
        <div v-if="member.teams && member.teams.length > 0">
          <div
            v-for="team in member.teams"
            :key="team.id"
            class="d-flex align-items-center mb-1"
          >
            <span>{{ team.name }}</span>
            <router-link
              :to="`/teams/${team.id}/members`"
              class="btn btn-outline-primary btn-sm ms-2"
            >
              Ver Time
            </router-link>
          </div>
        </div>
        <span v-else>Nenhum time</span>
      </td>
      <td class="d-flex gap-2">
        <router-link
          :to="`/members/edit/${member.id}`"
          class="btn btn-primary btn-sm"
        >
          Editar
        </router-link>
        <button class="btn btn-danger btn-sm" @click="deleteRecord(member.id)">
          Deletar
        </button>
      </td>
    </template>
  </BaseList>
</template>

<script>
import { getMembers, deleteMember } from "@/api/members";
import BaseList from "../common/BaseList.vue";

export default {
  name: "MembersList",
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
      try {
        const response = await getMembers(params);
        this.members = response.records;
        this.totalPages = response.total_pages || 1;
        this.isLoading = false;
      } catch (error) {
        this.isLoading = false;
        let message =
          error?.response?.data?.errors?.[0] || "Erro ao buscar membros";
        this.$eventBus.emit("displayAlert", message);
      }
    },
    async deleteRecord(id) {
      if (confirm("Tem certeza que deseja deletar este membro?")) {
        try {
          await deleteMember(id);
          this.handleFetch({ page: 1 });
        } catch (error) {
          let message =
            error?.response?.data?.errors?.[0] || "Erro ao deletar membro";
          this.$eventBus.emit("displayAlert", message);
        }
      }
    },
  },
};
</script>
