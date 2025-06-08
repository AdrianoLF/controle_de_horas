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
      <td>
        <router-link :to="`/events/${event.id}`" class="text-decoration-none">
          {{ event.title }}
        </router-link>
      </td>
      <td>{{ getTeamName(event.team_id) }}</td>
      <td>{{ formatDuration(event.duration_seconds) }}</td>
      <td>
        <router-link
          :to="{ name: 'EventEdit', params: { id: event.id } }"
          class="btn btn-info btn-sm"
        >
          {{ event.members?.length || 0 }}
        </router-link>
      </td>
      <td class="d-flex gap-2">
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
import { handleRequest } from "@/helper/request";
import { getEvents, deleteEvent as deleteEventApi } from "@/api/events";
import { getTeams } from "@/api/teams";
import BaseList from "../common/BaseList.vue";

export default {
  name: "EventsList",

  components: {
    BaseList,
  },

  data() {
    return {
      events: [],
      teams: [],
      isLoading: true,
      totalPages: 1,
      deleteModal: false,
      eventToDelete: null,
    };
  },

  mounted() {
    this.loadTeams();
  },

  methods: {
    async handleFetch(params) {
      await handleRequest({
        request: () => getEvents(params),
        processOnSuccess: (response) => {
          this.events = response.records;
          this.totalPages = response.total_pages;
        },
        errorMessage: "Erro ao carregar eventos",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    async loadTeams() {
      await handleRequest({
        request: () => getTeams({ all_records: true }),
        processOnSuccess: (response) => {
          this.teams = response.records;
        },
        errorMessage: "Erro ao carregar times",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    getTeamName(teamId) {
      const team = this.teams.find((t) => t.id === teamId);
      return team ? team.name : "-";
    },

    formatDuration(seconds) {
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);

      if (hours > 0) {
        return `${hours}h${minutes > 0 ? ` ${minutes}min` : ""}`;
      }
      return `${minutes}min`;
    },

    confirmDelete(event) {
      this.eventToDelete = event;
      this.deleteModal = true;
    },

    async deleteEvent() {
      await handleRequest({
        request: () => deleteEventApi(this.eventToDelete.id),
        processOnSuccess: () => {
          this.handleFetch();
          this.deleteModal = false;
          this.eventToDelete = null;
        },
        successMessage: "Evento excluído com sucesso",
        errorMessage: "Erro ao excluir evento",
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },
  },
};
</script>
