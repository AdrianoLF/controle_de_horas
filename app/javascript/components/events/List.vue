<template>
  <BaseList
    title="Lista de Eventos"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Novo Evento"
    new-item-route="/events/new"
    :headers="['Nome', 'Time', 'Duração', 'Membros', 'Ações']"
    :items="events"
    :total-pages="totalPages"
    :is-loading="isLoading"
    :fetch-function="handleFetch"
    @fetch="handleFetch"
  >
    <template #row="{ item: event }">
      <td>{{ event.title }}</td>
      <td>{{ getTeamName(event.team_id) }}</td>
      <td>{{ formatDuration(event.duration_seconds) }}</td>
      <td>
        <router-link
          :to="{ name: 'EventMembers', params: { id: event.id } }"
          class="btn btn-info btn-sm"
        >
          Membros
        </router-link>
      </td>
      <td class="d-flex gap-2">
        <router-link
          :to="{ name: 'EventEdit', params: { id: event.id } }"
          class="btn btn-primary btn-sm"
        >
          Editar
        </router-link>
        <button class="btn btn-danger btn-sm" @click="confirmDelete(event)">
          Excluir
        </button>
      </td>
    </template>
  </BaseList>

  <!-- Modal de confirmação de exclusão -->
  <div
    v-if="deleteModal"
    class="fixed inset-0 z-10 flex items-center justify-center"
  >
    <div class="absolute inset-0 bg-black opacity-50"></div>
    <div class="bg-white p-6 rounded-lg z-20 max-w-md w-full">
      <h2 class="text-xl font-bold mb-4">Confirmar exclusão</h2>
      <p class="mb-6">
        Tem certeza que deseja excluir o evento "{{ eventToDelete?.title }}"?
      </p>
      <div class="flex justify-end space-x-3">
        <button
          @click="deleteModal = false"
          class="px-4 py-2 bg-gray-300 hover:bg-gray-400 rounded"
        >
          Cancelar
        </button>
        <button
          @click="deleteEvent"
          class="px-4 py-2 bg-red-500 hover:bg-red-600 text-white rounded"
        >
          Excluir
        </button>
      </div>
    </div>
  </div>
</template>

<script>
import { ref, reactive } from "vue";
import { getEvents, deleteEvent as deleteEventApi } from "@/api/events";
import { getTeams } from "@/api/teams";
import BaseList from "../common/BaseList.vue";

export default {
  components: {
    BaseList,
  },

  setup() {
    const events = ref([]);
    const teams = ref([]);
    const isLoading = ref(true);
    const totalPages = ref(1);
    const deleteModal = ref(false);
    const eventToDelete = ref(null);

    const handleFetch = async (params) => {
      try {
        isLoading.value = true;
        const response = await getEvents(params);
        events.value = response.events;
        totalPages.value = response.total_pages;
        isLoading.value = false;

        loadTeams();
      } catch (error) {
        console.error("Erro ao carregar eventos:", error);
        isLoading.value = false;
      }
    };

    const loadTeams = async () => {
      try {
        const response = await getTeams({ all_teams: true });
        teams.value = response.teams;
      } catch (error) {
        console.error("Erro ao carregar times:", error);
      }
    };

    const getTeamName = (teamId) => {
      const team = teams.value.find((t) => t.id === teamId);
      return team ? team.name : "Time não encontrado";
    };

    const formatDuration = (seconds) => {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);

      if (hours > 0) {
        return `${hours}h${minutes > 0 ? ` ${minutes}min` : ""}`;
      }
      return `${minutes}min`;
    };

    const confirmDelete = (event) => {
      eventToDelete.value = event;
      deleteModal.value = true;
    };

    const deleteEvent = async () => {
      try {
        await deleteEventApi(eventToDelete.value.id);
        await handleFetch({ page: 1 });
        deleteModal.value = false;
        eventToDelete.value = null;
      } catch (error) {
        console.error("Erro ao excluir evento:", error);
      }
    };

    return {
      events,
      teams,
      isLoading,
      totalPages,
      deleteModal,
      eventToDelete,
      handleFetch,
      getTeamName,
      formatDuration,
      confirmDelete,
      deleteEvent,
    };
  },
};
</script>
