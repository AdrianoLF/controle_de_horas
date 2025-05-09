<template>
  <div class="container mt-5">
    <h1 class="mb-4">{{ title }}</h1>

    <div class="row mb-3">
      <div class="col-md-9">
        <input
          type="text"
          class="form-control"
          :placeholder="searchPlaceholder"
          v-model="searchTerm"
          @input="handleSearch"
        />
      </div>
      <div class="col-md-3">
        <button class="btn btn-primary w-100" @click="fetchData">Buscar</button>
      </div>
    </div>

    <div class="mb-4">
      <router-link :to="newItemRoute" class="btn btn-success">
        {{ addButtonText }}
      </router-link>
    </div>

    <table class="table table-striped table-bordered">
      <thead class="thead-dark">
        <tr>
          <th scope="col" v-for="header in headers" :key="header">
            {{ header }}
          </th>
        </tr>
      </thead>
      <tbody>
        <tr v-if="isLoading">
          <td :colspan="headers.length" class="text-center">Carregando...</td>
        </tr>
        <tr v-else v-for="item in items" :key="item.id">
          <slot name="row" :item="item"></slot>
        </tr>
      </tbody>
    </table>

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
import debounce from "lodash.debounce";
import { mapGetters } from "vuex";

export default {
  name: "BaseList",
  props: {
    title: {
      type: String,
      required: true,
    },
    searchPlaceholder: {
      type: String,
      default: "Pesquisar",
    },
    addButtonText: {
      type: String,
      required: true,
    },
    newItemRoute: {
      type: String,
      required: true,
    },
    headers: {
      type: Array,
      required: true,
    },
    fetchFunction: {
      type: Function,
      required: true,
    },
    items: {
      type: Array,
      required: true,
    },
    totalPages: {
      type: Number,
      required: true,
    },
    isLoading: {
      type: Boolean,
      required: true,
    },
  },
  data() {
    return {
      searchTerm: "",
      currentPage: 1,
    };
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
  },
  watch: {
    searchTerm() {
      this.currentPage = 1;
    },
  },
  created() {
    this.handleSearch = debounce(this.fetchData, 300);
  },
  mounted() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      const params = {
        page: this.currentPage,
        name: this.searchTerm,
        title: this.searchTerm,
      };
      this.$emit("fetch", params);
    },
    changePage(page) {
      if (page < 1 || page > this.totalPages) return;
      this.currentPage = page;
      this.fetchData();
    },
  },
};
</script>
