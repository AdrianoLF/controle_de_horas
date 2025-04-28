<template>
  <BaseList
    title="Lista de Membros"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Membro"
    new-item-route="/members/new"
    :headers="['#', 'Nome', '', '']"
    :items="members"
    :total-pages="totalPages"
    :is-loading="isLoading"
    @fetch="handleFetch"
  >
    <template #row="{ item: member }">
      <th scope="row">{{ member.id }}</th>
      <td>{{ member.name }}</td>
      <td>
        <router-link
          :to="`/members/edit/${member.id}`"
          class="btn btn-primary btn-sm"
        >
          Editar
        </router-link>
      </td>
      <td>
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
        this.members = response.members;
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
