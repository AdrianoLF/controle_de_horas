<template>
  <BaseList
    ref="baseList"
    title="Lista de Eventos"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Novo Evento"
    :headers="headers"
    :items="events"
    :total-pages="totalPages"
    :is-loading="isLoading"
    :has-filters="true"
    :active-filters-count="activeFiltersCount"
    @fetch="handleFetch"
    @add-new="openCreateModal"
    @toggle-filters="showFiltersModal = true"
  >
    <template #active-filters v-if="hasAnyFilters && activeFiltersText">
      <div class="d-flex align-items-center justify-content-between">
        <span>
          <i class="filter-indicator"></i>
          {{ activeFiltersText }}
        </span>
        <button
          class="btn btn-sm btn-outline-secondary"
          @click="clearAllFilters"
        >
          Limpar Filtros
        </button>
      </div>
    </template>

    <template #row="{ item: event }">
      <td>
        <button
          @click="openEditModal(event.id)"
          class="btn btn-link text-decoration-none p-0 text-start"
        >
          {{ event.title }}
        </button>
      </td>
      <td>{{ formatDate(event.occurred_at) }}</td>
      <td>{{ event.team?.name || "-" }}</td>
      <td>{{ formatDuration(event.duration_seconds) }}</td>
      <td>
        <button @click="openEditModal(event.id)" class="btn btn-info btn-sm">
          {{ event.members_count || 0 }}
        </button>
      </td>
      <td class="d-flex gap-2">
        <button
          class="btn btn-outline-secondary btn-sm"
          @click="openEditModal(event.id)"
        >
          Editar
        </button>
        <button class="btn btn-danger btn-sm" @click="confirmDelete(event)">
          Excluir
        </button>
      </td>
    </template>
  </BaseList>

  <EventModal
    :show="showModal"
    :event-id="selectedEventId"
    @close="closeModal"
    @saved="handleEventSaved"
  />

  <FiltersModal
    :show="showFiltersModal"
    @close="showFiltersModal = false"
    @apply="applyFilters"
    @clear="clearAllFilters"
  >
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label">Data Inicial</label>
        <input type="date" class="form-control" v-model="filterDateStart" />
      </div>
      <div class="col-md-6">
        <label class="form-label">Data Final</label>
        <input type="date" class="form-control" v-model="filterDateEnd" />
      </div>

      <div class="col-12">
        <label class="form-label">Times</label>
        <select class="form-select" v-model="selectedTeamIds" multiple size="8">
          <option
            v-for="team in availableTeams"
            :key="team.id"
            :value="team.id"
          >
            {{ team.name }}
          </option>
        </select>
        <small class="form-text text-muted">
          Segure Ctrl/Cmd para selecionar múltiplos.
        </small>
      </div>
    </div>
  </FiltersModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getEvents, deleteEvent } from "@/api/events";
import { getTeams } from "@/api/teams";
import BaseList from "../common/BaseList.vue";
import EventModal from "./EventModal.vue";
import FiltersModal from "../common/FiltersModal.vue";

export default {
  name: "EventsList",

  components: {
    BaseList,
    EventModal,
    FiltersModal,
  },

  data() {
    return {
      // ===== DADOS DA LISTA =====
      events: [],
      totalPages: 1,
      isLoading: true,
      headers: [
        { label: "Nome", key: "title", sortable: true },
        { label: "Data", key: "occurred_at", sortable: true },
        { label: "Time", key: "team_name", sortable: true },
        { label: "Duração", key: "duration_seconds", sortable: true },
        { label: "Membros", key: "members_count", sortable: true },
        { label: "Ações", key: "actions", sortable: false },
      ],

      // ===== MODAIS =====
      showModal: false,
      showFiltersModal: false,
      selectedEventId: null,

      // ===== FILTROS =====
      selectedTeamIds: [],
      availableTeams: [],
      filterDateStart: "",
      filterDateEnd: "",
    };
  },

  computed: {
    activeFiltersCount() {
      let count = 0;
      if (this.selectedTeamIds.length > 0) count += 1;
      if (this.filterDateStart || this.filterDateEnd) count += 1;
      return count;
    },
    hasAnyFilters() {
      return (
        this.selectedTeamIds.length > 0 ||
        this.filterDateStart !== "" ||
        this.filterDateEnd !== ""
      );
    },
    activeFiltersText() {
      if (!this.hasAnyFilters) return "Exibindo todos os eventos.";

      const parts = [];

      if (this.selectedTeamIds.length > 0) {
        const teamNames = this.selectedTeamIds
          .map((id) => this.availableTeams.find((team) => team.id === id)?.name)
          .filter(Boolean)
          .join(", ");
        parts.push(`Times: ${teamNames}`);
      }

      if (this.filterDateStart || this.filterDateEnd) {
        const start = this.filterDateStart
          ? new Date(this.filterDateStart).toLocaleDateString("pt-BR")
          : "";
        const end = this.filterDateEnd
          ? new Date(this.filterDateEnd).toLocaleDateString("pt-BR")
          : "";
        parts.push(`Período: ${start || "…"} - ${end || "…"}`);
      }

      return parts.join(" • ");
    },
  },

  mounted() {
    this.loadAvailableTeams();
  },

  methods: {
    // ===== MÉTODOS PRINCIPAIS =====
    async handleFetch(params) {
      await handleRequest({
        request: () => getEvents(params),
        processOnSuccess: (response) => {
          this.events = response.records;
          this.totalPages = response.total_pages;
        },
        errorMessage: "Erro ao carregar eventos",
        eventBus: this.$eventBus,
        processOnStart: () => (this.isLoading = true),
        processOnFinally: () => (this.isLoading = false),
      });
    },

    async confirmDelete(event) {
      if (
        !confirm(`Tem certeza que deseja excluir o evento "${event.title}"?`)
      ) {
        return;
      }

      await handleRequest({
        request: () => deleteEvent(event.id),
        processOnSuccess: () => this.$refs.baseList?.fetchData(),
        successMessage: "Evento excluído com sucesso",
        errorMessage: "Erro ao excluir evento",
        eventBus: this.$eventBus,
      });
    },

    formatDuration(seconds) {
      if (!seconds) return "-";
      const hours = Math.floor(seconds / 3600);
      const minutes = Math.floor((seconds % 3600) / 60);

      if (hours > 0) {
        return `${hours}h${minutes > 0 ? ` ${minutes}min` : ""}`;
      }
      return `${minutes}min`;
    },

    formatDate(dateString) {
      if (!dateString) return "-";
      const date = new Date(dateString);
      // Adjust for timezone offset to prevent day-before issues
      const userTimezoneOffset = date.getTimezoneOffset() * 60000;
      return new Date(date.getTime() + userTimezoneOffset).toLocaleDateString(
        "pt-BR",
        {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        }
      );
    },

    // ===== MODAIS =====
    openCreateModal() {
      this.selectedEventId = null;
      this.showModal = true;
    },

    openEditModal(eventId) {
      this.selectedEventId = eventId;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.selectedEventId = null;
    },

    handleEventSaved() {
      this.$refs.baseList?.fetchData();
    },

    // ===== FILTROS =====
    applyFilters() {
      const filters = {};

      if (this.selectedTeamIds.length > 0) {
        filters.team_ids = this.selectedTeamIds;
      }

      if (this.filterDateStart) {
        filters.occurred_from = this.filterDateStart;
      }
      if (this.filterDateEnd) {
        filters.occurred_to = this.filterDateEnd;
      }

      this.$refs.baseList?.applyFilters(filters);
    },

    clearAllFilters() {
      this.selectedTeamIds = [];
      this.filterDateStart = "";
      this.filterDateEnd = "";
      this.$refs.baseList?.resetToInitialState();
    },

    async loadAvailableTeams() {
      await handleRequest({
        request: () => getTeams({ all_records: true }),
        processOnSuccess: (response) => {
          this.availableTeams = response.records;
        },
        errorMessage: "Erro ao carregar times",
        eventBus: this.$eventBus,
      });
    },
  },
};
</script>

<style scoped>
.btn-link.text-start {
  color: #0d6efd !important;
  font-weight: 500;
}

.btn-link.text-start:hover {
  color: #0a58ca !important;
  text-decoration: underline !important;
}

.filter-indicator::before {
  content: "🔍";
  margin-right: 0.5rem;
}
</style>
