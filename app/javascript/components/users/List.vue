<template>
  <BaseList
    ref="baseList"
    title="Gerenciar Usuários"
    search-placeholder="Pesquisar por Nome ou Email"
    add-button-text="Novo Usuário"
    :headers="headers"
    :items="users"
    :total-pages="totalPages"
    :is-loading="isLoading"
    :has-filters="true"
    :active-filters-count="activeFiltersCount"
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

    <template #row="{ item: user }">
      <td>
        <div class="d-flex align-items-center">
          <div
            :class="
              user.suspended ? 'status-dot inactive' : 'status-dot active'
            "
            :title="user.suspended ? 'Suspenso' : 'Ativo'"
          ></div>
          <div class="ms-2">
            <div class="fw-semibold">{{ user.name || "Sem nome" }}</div>
            <small class="text-muted">{{ user.email }}</small>
          </div>
        </div>
      </td>
      <td>
        <span v-if="user.super_admin" class="badge bg-danger">Super Admin</span>
        <span v-else class="badge bg-secondary">Usuário</span>
      </td>
      <td>
        <span v-if="user.suspended" class="badge bg-warning">Suspenso</span>
        <span v-else class="badge bg-success">Ativo</span>
      </td>
      <td>
        {{ formatDate(user.created_at) }}
      </td>
      <td>
        <div class="btn-group" role="group">
          <button
            class="btn btn-outline-primary btn-sm"
            @click="openEditModal(user)"
            :disabled="isLoading"
          >
            <i class="fas fa-edit me-1"></i>
            Editar
          </button>
          <button
            class="btn btn-outline-info btn-sm"
            @click="generateNewPassword(user)"
            :disabled="isLoading"
          >
            <i class="fas fa-key me-1"></i>
            Reset Senha
          </button>
        </div>
      </td>
    </template>
  </BaseList>

  <UserCreateModal ref="createModal" @user-created="handleUserCreated" />

  <UserEditModal
    :show="showEditModal"
    :user="selectedUser"
    @close="closeEditModal"
    @saved="handleUserSaved"
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
        <select class="form-select" v-model="filterStatus">
          <option value="">Todos</option>
          <option value="active">Ativos</option>
          <option value="suspended">Suspensos</option>
        </select>
      </div>
      <div class="col-md-6">
        <label class="form-label">Tipo de Usuário</label>
        <select class="form-select" v-model="filterUserType">
          <option value="">Todos</option>
          <option value="super_admin">Super Admins</option>
          <option value="regular">Usuários Regulares</option>
        </select>
      </div>
    </div>
  </FiltersModal>

  <PasswordResetModal
    :show="showPasswordModal"
    :user="selectedUserForPassword"
    :new-password="newPassword"
    @close="closePasswordModal"
  />
</template>

<script>
import { handleRequest } from "@/helper/request";
import { getUsers, editUser } from "@/api/superadmin/users";
import BaseList from "../common/BaseList.vue";
import FiltersModal from "../common/FiltersModal.vue";
import UserCreateModal from "./UserCreateModal.vue";
import UserEditModal from "./UserEditModal.vue";
import PasswordResetModal from "./PasswordResetModal.vue";

export default {
  name: "UsersList",
  components: {
    BaseList,
    FiltersModal,
    UserCreateModal,
    UserEditModal,
    PasswordResetModal,
  },
  data() {
    return {
      users: [],
      totalPages: 1,
      isLoading: false,
      showEditModal: false,
      showFiltersModal: false,
      showPasswordModal: false,
      selectedUser: null,
      selectedUserForPassword: null,
      newPassword: "",

      filterStatus: "",
      filterUserType: "",

      headers: [
        { key: "user", title: "Usuário", sortable: false },
        { key: "type", title: "Tipo", sortable: false },
        { key: "status", title: "Status", sortable: false },
        { key: "created_at", title: "Criado em", sortable: false },
        { key: "actions", title: "Ações", sortable: false },
      ],
    };
  },
  computed: {
    hasAnyFilters() {
      return this.filterStatus || this.filterUserType;
    },
    activeFiltersCount() {
      let count = 0;
      if (this.filterStatus) count++;
      if (this.filterUserType) count++;
      return count;
    },
    activeFiltersText() {
      const filters = [];
      if (this.filterStatus) {
        const statusText =
          this.filterStatus === "active" ? "Ativos" : "Suspensos";
        filters.push(`Status: ${statusText}`);
      }
      if (this.filterUserType) {
        const typeText =
          this.filterUserType === "super_admin"
            ? "Super Admins"
            : "Usuários Regulares";
        filters.push(`Tipo: ${typeText}`);
      }
      return filters.length > 0 ? filters.join(", ") : "Nenhum filtro aplicado";
    },
  },

  methods: {
    async handleFetch(params) {
      await this.fetchUsers(params);
    },

    async fetchUsers(params = {}) {
      this.isLoading = true;

      const searchParams = {
        ...params,
        status: this.filterStatus || undefined,
      };

      await handleRequest({
        request: () => getUsers(searchParams),
        processOnSuccess: (response) => {
          this.users = this.processUsers(response.records || []);
          this.totalPages = response.total_pages || 1;
        },
        errorMessage: "Erro ao carregar usuários",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    processUsers(users) {
      return users.filter((user) => {
        if (this.filterUserType === "super_admin") {
          return user.super_admin;
        } else if (this.filterUserType === "regular") {
          return !user.super_admin;
        }
        return true;
      });
    },

    openCreateModal() {
      this.$refs.createModal.show();
    },

    handleUserCreated() {
      this.fetchUsers();
    },

    openEditModal(user) {
      this.selectedUser = { ...user };
      this.showEditModal = true;
    },

    closeEditModal() {
      this.showEditModal = false;
      this.selectedUser = null;
    },

    async handleUserSaved() {
      this.closeEditModal();
      await this.fetchUsers();
      this.$eventBus.showAlert("Usuário atualizado com sucesso!", "success");
    },

    async generateNewPassword(user) {
      if (
        !confirm(
          `Tem certeza que deseja resetar a senha do usuário ${user.name || user.email}?`
        )
      ) {
        return;
      }

      this.isLoading = true;
      const newPassword = this.generateRandomPassword();

      await handleRequest({
        request: () =>
          editUser(user.id, {
            user: {
              password: newPassword,
              password_confirmation: newPassword,
            },
          }),
        processOnSuccess: () => {
          this.selectedUserForPassword = user;
          this.newPassword = newPassword;
          this.showPasswordModal = true;
          this.fetchUsers();
        },
        errorMessage: "Erro ao resetar senha",
        eventBus: this.$eventBus,
        processOnFinally: () => {
          this.isLoading = false;
        },
      });
    },

    generateRandomPassword() {
      const uppercase = "ABCDEFGHIJKLMNOPQRSTUVWXYZ";
      const lowercase = "abcdefghijklmnopqrstuvwxyz";
      const numbers = "0123456789";
      const special = "!@#$%";

      let password = "";
      password += uppercase[Math.floor(Math.random() * uppercase.length)];
      password += lowercase[Math.floor(Math.random() * lowercase.length)];
      password += numbers[Math.floor(Math.random() * numbers.length)];
      password += special[Math.floor(Math.random() * special.length)];

      const allChars = uppercase + lowercase + numbers + special;
      for (let i = 4; i < 12; i++) {
        password += allChars[Math.floor(Math.random() * allChars.length)];
      }

      return password
        .split("")
        .sort(() => 0.5 - Math.random())
        .join("");
    },

    closePasswordModal() {
      this.showPasswordModal = false;
      this.selectedUserForPassword = null;
      this.newPassword = "";
    },

    applyFilters() {
      this.showFiltersModal = false;
      this.$refs.baseList.applyFilters({ status: this.filterStatus });
    },

    clearAllFilters() {
      this.filterStatus = "";
      this.filterUserType = "";
      this.showFiltersModal = false;
      this.$refs.baseList.clearFilters();
    },

    formatDate(dateString) {
      if (!dateString) return "-";
      try {
        const date = new Date(dateString);
        return date.toLocaleDateString("pt-BR", {
          day: "2-digit",
          month: "2-digit",
          year: "numeric",
        });
      } catch {
        return "-";
      }
    },
  },
};
</script>

<style scoped>
.status-dot {
  width: 8px;
  height: 8px;
  border-radius: 50%;
  display: inline-block;
}

.status-dot.active {
  background-color: #28a745;
}

.status-dot.inactive {
  background-color: #dc3545;
}

.filter-indicator {
  width: 8px;
  height: 8px;
  background-color: #007bff;
  border-radius: 50%;
  display: inline-block;
  margin-right: 8px;
}

.btn-group {
  white-space: nowrap;
}

.btn-group .btn {
  font-size: 0.75rem;
  padding: 0.25rem 0.5rem;
}
</style>
