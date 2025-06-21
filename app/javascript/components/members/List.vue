<template>
  <BaseList
    ref="baseList"
    title="Lista de Membros"
    search-placeholder="Pesquisar por Nome"
    add-button-text="Adicionar Membro"
    :headers="headers"
    :items="members"
    :total-pages="totalPages"
    :is-loading="isLoading"
    :has-filters="true"
    :active-filters-count="activeFiltersCount"
    :initial-filters="{ active: true }"
    @fetch="handleFetch"
    @add-new="openCreateModal"
    @toggle-filters="showFiltersModal = true"
  >
    <template #active-filters>
      <div class="d-flex align-items-center justify-content-between">
        <span>
          <i class="filter-indicator"></i>
          {{ activeFiltersText }}
        </span>
        <button
          v-if="hasAnyFilters"
          class="btn btn-sm btn-outline-secondary"
          @click="clearAllFilters"
        >
          Limpar Filtros
        </button>
      </div>
    </template>

    <template #row="{ item: member }">
      <td>
        <div class="d-flex align-items-center">
          <div
            :class="member.active ? 'status-dot active' : 'status-dot inactive'"
            :title="
              member.active
                ? 'Ativo'
                : `Desativado em ${
                    member.disabled_at
                      ? new Date(member.disabled_at).toLocaleDateString(
                          'pt-BR',
                          {
                            day: '2-digit',
                            month: '2-digit',
                            year: 'numeric',
                          }
                        )
                      : ''
                  }`
            "
          ></div>
          <button
            @click="openEditModal(member.id)"
            class="btn btn-link text-decoration-none ms-2 p-0 text-start"
          >
            {{ member.name }}
          </button>
        </div>
      </td>
      <td>
        <div
          v-if="member.teams && member.teams.length > 0"
          class="d-flex gap-1"
        >
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
        <button
          class="btn btn-outline-secondary btn-sm"
          @click="openEditModal(member.id)"
        >
          Editar
        </button>
        <button
          :class="
            member.active ? 'btn btn-warning btn-sm' : 'btn btn-success btn-sm'
          "
          @click="toggleActive(member.id, !member.active)"
        >
          {{ member.active ? "Desativar" : "Ativar" }}
        </button>
      </td>
    </template>
  </BaseList>

  <MemberModal
    :show="showModal"
    :member-id="selectedMemberId"
    @close="closeModal"
    @saved="handleMemberSaved"
  />

  <FiltersModal
    :show="showFiltersModal"
    @close="showFiltersModal = false"
    @apply="applyFilters"
    @clear="clearAllFilters"
  >
    <div class="row g-3">
      <div class="col-md-6">
        <label class="form-label">Status</label>
        <select class="form-select" v-model="filterActive">
          <option value="">Todos</option>
          <option :value="true">Ativos</option>
          <option :value="false">Inativos</option>
        </select>
      </div>
      <div class="col-md-6">
        <label class="form-label">Times</label>
        <select class="form-select" v-model="selectedTeamIds" multiple size="5">
          <option
            v-for="team in availableTeams"
            :key="team.id"
            :value="team.id"
          >
            {{ team.name }}
          </option>
        </select>
        <small class="form-text text-muted">
          Segure Ctrl/Cmd para selecionar múltiplos
        </small>
      </div>
    </div>
  </FiltersModal>
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getMembers, editMember } from "@/api/members";
import { getTeams } from "@/api/teams";
import BaseList from "../common/BaseList.vue";
import MemberModal from "./MemberModal.vue";
import FiltersModal from "../common/FiltersModal.vue";

export default {
  name: "MembersList",
  components: {
    BaseList,
    MemberModal,
    FiltersModal,
  },
  data() {
    return {
      // ===== DADOS DA LISTA =====
      members: [],
      totalPages: 1,
      isLoading: true,
      headers: [
        { label: "Nome", key: "name", sortable: true },
        { label: "Times", key: "teams", sortable: false },
        { label: "Ações", key: "actions", sortable: false },
      ],

      // ===== MODAIS =====
      showModal: false,
      showFiltersModal: false,
      selectedMemberId: null,

      // ===== FILTROS =====
      filterActive: true, // Padrão: apenas membros ativos
      selectedTeamIds: [], // Times selecionados para filtro
      availableTeams: [], // Lista de todos os times disponíveis
    };
  },
  computed: {
    activeFiltersCount() {
      let count = 0;
      if (this.filterActive === false || this.filterActive === "") count++; // Só conta se não for o padrão (true)
      if (this.selectedTeamIds.length > 0) count++;
      return count;
    },

    hasAnyFilters() {
      return this.filterActive !== true || this.selectedTeamIds.length > 0;
    },

    // Texto descritivo dos filtros ativos
    activeFiltersText() {
      const parts = [];

      // Status dos membros
      const statusText = this.getStatusText();
      parts.push(statusText);

      // Filtro por times
      const teamsText = this.getTeamsText();
      if (teamsText) parts.push(teamsText);

      return parts.join(" • ");
    },
  },
  mounted() {
    this.loadAvailableTeams();
  },
  methods: {
    // ===== MÉTODOS AUXILIARES =====
    getStatusText() {
      switch (this.filterActive) {
        case true:
          return "Exibindo apenas membros ativos";
        case false:
          return "Exibindo apenas membros inativos";
        case "":
          return "Exibindo todos os membros";
        default:
          return "Exibindo apenas membros ativos";
      }
    },

    getTeamsText() {
      if (this.selectedTeamIds.length === 0) return null;

      const teamNames = this.selectedTeamIds
        .map((id) => this.availableTeams.find((team) => team.id === id)?.name)
        .filter(Boolean);

      return `Times: ${teamNames.join(", ")}`;
    },

    // ===== MÉTODOS PRINCIPAIS =====
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
    // ===== AÇÕES DE MEMBROS =====
    async toggleActive(id, active) {
      const member = this.members.find((m) => m.id === id);
      const action = active ? "ativar" : "desativar";
      const confirmMessage = `Tem certeza que deseja ${action} o membro "${member.name}"?`;

      if (!confirm(confirmMessage)) return;

      await handleRequest({
        request: () => editMember(id, { active }),
        processOnSuccess: () => {
          // Reaplica os filtros atuais ao invés de resetar
          this.$refs.baseList?.fetchData();
        },
        successMessage: `Membro ${active ? "ativado" : "desativado"} com sucesso`,
        errorMessage: `Erro ao ${action} membro`,
        eventBus: this.$eventBus,
        processOnStart: () => {
          this.isLoading = true;
        },
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    // ===== MODAIS =====
    openCreateModal() {
      this.selectedMemberId = null;
      this.showModal = true;
    },

    openEditModal(memberId) {
      this.selectedMemberId = memberId;
      this.showModal = true;
    },

    closeModal() {
      this.showModal = false;
      this.selectedMemberId = null;
    },

    handleMemberSaved() {
      // Mantém os filtros atuais após salvar
      this.$refs.baseList?.fetchData();
    },

    // ===== FILTROS =====
    applyFilters() {
      const filters = {};

      filters.active = this.filterActive;

      if (this.selectedTeamIds.length > 0) {
        filters.team_ids = this.selectedTeamIds;
      }

      this.$refs.baseList?.applyFilters(filters);
    },

    clearAllFilters() {
      this.filterActive = true;
      this.selectedTeamIds = [];
      this.$refs.baseList?.resetToInitialState();
    },

    // ===== DADOS AUXILIARES =====
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
.status-dot {
  width: 12px;
  height: 12px;
  border-radius: 50%;
  display: inline-block;
  flex-shrink: 0;
}

.status-dot.active {
  background-color: #28a745;
}

.status-dot.inactive {
  background-color: #dc3545;
}

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
