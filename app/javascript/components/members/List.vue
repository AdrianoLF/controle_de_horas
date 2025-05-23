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
      <td>
        <router-link :to="`/members/${member.id}`" class="text-decoration-none">
          {{ member.name }}
        </router-link>
      </td>
      <td>
        <div v-if="member.teams && member.teams.length > 0">
          <div
            v-for="team in member.teams"
            :key="team.id"
            class="d-flex align-items-center mb-1"
          >
            <router-link
              :to="`/teams/${team.id}/members`"
              class="btn btn-outline-primary btn-sm ms-2"
            >
              <span>{{ team.name }}</span>
            </router-link>
          </div>
        </div>
        <span v-else>Nenhum time</span>
      </td>
      <td class="d-flex gap-2">
        <button class="btn btn-danger btn-sm" @click="deleteRecord(member.id)">
          Excluir
        </button>
      </td>
    </template>
  </BaseList>
</template>

<script>
import { handleRequest } from "@/helper/request";
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
      await handleRequest({
        request: () => getMembers(params),
        processOnSuccess: (response) => {
          this.members = response.records;
          this.totalPages = response.total_pages || 1;
          this.isLoading = false;
        },
        errorMessage: "Erro ao buscar membros",
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
      if (
        confirm("Tem certeza que deseja excluir PERMANENTEMENTE este membro?")
      ) {
        await handleRequest({
          request: () => deleteMember(id),
          processOnSuccess: () => {
            this.handleFetch({ page: 1 });
          },
          successMessage: "Membro excluído com sucesso",
          errorMessage: "Erro ao excluir membro",
          eventBus: this.$eventBus,
          processOnStart: () => {
            this.isLoading = true;
          },
          processOnFinally: () => {
            this.isLoading = false;
          },
        });
      }
    },
  },
};
</script>
