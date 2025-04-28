<template>
  <div class="container mt-5">
    <h1 class="mb-4">Lista de Times</h1>

    <!-- Barra de Pesquisa -->
    <div class="row mb-3">
      <div class="col-md-9">
        <input
          type="text"
          class="form-control"
          placeholder="Pesquisar por Nome"
          v-model="searchName"
          @input="debouncedFetchTeams"
        />
      </div>
      <div class="col-md-3">
        <button class="btn btn-primary w-100" @click="fetchTeams">
          Buscar
        </button>
      </div>
    </div>

    <!-- Botão para Adicionar Time -->
    <div class="mb-4">
      <router-link to="/teams/new" class="btn btn-success">
        Adicionar Time
      </router-link>
    </div>

    <!-- Tabela de Times -->
    <table class="table table-striped table-bordered">
      <thead class="thead-dark">
        <tr>
          <th scope="col">#</th>
          <th scope="col">Nome</th>
          <th scope="col">Membros</th>
          <th scope="col"></th>
          <th scope="col"></th>
          <th scope="col"></th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="isLoading">
          <td colspan="6" class="text-center">Carregando...</td>
        </tr>
        <tr v-else v-for="team in teams" :key="team.id">
          <th scope="row">{{ team.id }}</th>
          <td>{{ team.name }}</td>
          <td>{{ team.member_count || 0 }}</td>
          <td>
            <router-link
              :to="`/teams/${team.id}/members`"
              class="btn btn-info btn-sm"
            >
              Membros
            </router-link>
          </td>
          <td>
            <router-link
              :to="`/teams/edit/${team.id}`"
              class="btn btn-primary btn-sm"
            >
              Editar
            </router-link>
          </td>
          <td>
            <button
              class="btn btn-danger btn-sm"
              @click="deleteRecord(team.id)"
            >
              Deletar
            </button>
          </td>
        </tr>
      </tbody>
    </table>

    <!-- Paginação -->
    <nav aria-label="Page navigation example">
      <ul class="pagination justify-content-center">
        <li class="page-item" :class="{ disabled: currentPage === 1 }">
          <a
            class="page-link"
            href="#"
            @click.prevent="changePage(currentPage - 1)"
          >
            Anterior
          </a>
        </li>

        <li
          class="page-item"
          v-for="page in totalPages"
          :key="page"
          :class="{ active: currentPage === page }"
        >
          <a class="page-link" href="#" @click.prevent="changePage(page)">
            {{ page }}
          </a>
        </li>

        <li class="page-item" :class="{ disabled: currentPage === totalPages }">
          <a
            class="page-link"
            href="#"
            @click.prevent="changePage(currentPage + 1)"
          >
            Próximo
          </a>
        </li>
      </ul>
    </nav>
  </div>
</template>

<script>
import { getTeams, deleteTeam } from "@/api/teams";
import { mapGetters } from "vuex";
import debounce from "lodash.debounce";

export default {
  name: "TeamsList",
  data() {
    return {
      teams: [],
      searchName: "",
      currentPage: 1,
      totalPages: 1,
      isLoading: true,
    };
  },
  watch: {
    searchName() {
      this.currentPage = 1;
    },
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
  },
  mounted() {
    this.fetchTeams();
    this.debouncedFetchTeams = debounce(this.fetchTeams, 300);
  },
  methods: {
    async fetchTeams() {
      try {
        const params = {
          page: this.currentPage,
          name: this.searchName,
        };
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
          this.fetchTeams();
        } catch (error) {
          let message =
            error?.response?.data?.errors?.[0] || "Erro ao deletar time";
          this.$eventBus.emit("displayAlert", message);
        }
      }
    },
    changePage(page) {
      if (page < 1 || page > this.totalPages) return;
      this.currentPage = page;
      this.fetchTeams();
    },
  },
};
</script>
