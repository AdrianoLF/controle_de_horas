<template>
  <div class="container mt-5">
    <h1 class="mb-4">Lista de Membros</h1>

    <!-- Barra de Pesquisa -->
    <div class="row mb-3">
      <div class="col-md-9">
        <input
          type="text"
          class="form-control"
          placeholder="Pesquisar por Nome"
          v-model="searchName"
          @input="debouncedFetchMembers"
        />
      </div>
      <div class="col-md-3">
        <button class="btn btn-primary w-100" @click="fetchMembers">
          Buscar
        </button>
      </div>
    </div>

    <!-- Botão para Adicionar Membro -->
    <div class="mb-4">
      <router-link to="/members/new" class="btn btn-success">
        Adicionar Membro
      </router-link>
    </div>

    <!-- Tabela de Membros -->
    <table class="table table-striped table-bordered">
      <thead class="thead-dark">
        <tr>
          <th scope="col">#</th>
          <th scope="col">Nome</th>
          <th scope="col"></th>
          <th scope="col"></th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="isLoading">
          Carregando...
        </tr>
        <tr v-else v-for="member in members" :key="member.id">
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
            <button
              class="btn btn-danger btn-sm"
              @click="deleteRecord(member.id)"
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
import { getMembers, deleteMember } from "@/api/members";
import { mapGetters } from "vuex";
import debounce from "lodash.debounce";

export default {
  name: "MembersList",
  data() {
    return {
      members: [],
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
    this.fetchMembers();
    this.debouncedFetchMembers = debounce(this.fetchMembers, 300);
  },
  methods: {
    async fetchMembers() {
      try {
        const params = {
          page: this.currentPage,
          name: this.searchName,
        };
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
          this.fetchMembers();
        } catch (error) {
          let message =
            error?.response?.data?.errors?.[0] || "Erro ao deletar membro";
          this.$eventBus.emit("displayAlert", message);
        }
      }
    },
    changePage(page) {
      if (page < 1 || page > this.totalPages) return;
      this.currentPage = page;
      this.fetchMembers();
    },
  },
};
</script>
