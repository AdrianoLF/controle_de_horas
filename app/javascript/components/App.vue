<template>
  <div id="app">
    <AlertBox />

    <nav
      v-if="isLoggedIn"
      class="navbar navbar-expand-lg navbar-dark bg-primary fixed-top shadow"
    >
      <div class="container-fluid">
        <router-link to="/" class="navbar-brand">MeuApp</router-link>
        <button
          class="navbar-toggler"
          type="button"
          data-bs-toggle="collapse"
          data-bs-target="#navbarNav"
          aria-controls="navbarNav"
          aria-expanded="false"
          aria-label="Alternar navegação"
        >
          <span class="navbar-toggler-icon"></span>
        </button>
        <div class="collapse navbar-collapse" id="navbarNav">
          <ul class="navbar-nav me-auto mb-2 mb-lg-0">
            <li class="nav-item">
              <router-link to="/" class="nav-link" active-class="active" exact>
                Relatórios
              </router-link>
            </li>
            <li class="nav-item">
              <router-link
                to="/proponents/new"
                class="nav-link"
                active-class="active"
                >Cadastrar Proponentes</router-link
              >
            </li>
            <li class="nav-item">
              <router-link to="/members" class="nav-link" active-class="active"
                >Membros</router-link
              >
            </li>
          </ul>
          <ul class="navbar-nav">
            <li class="nav-item" v-if="!isLoggedIn">
              <router-link to="/login" class="nav-link btn btn-outline-light"
                >Login</router-link
              >
            </li>
            <li class="nav-item" v-if="isLoggedIn">
              <button @click="logout" class="nav-link btn btn-outline-light">
                Logout
              </button>
            </li>
          </ul>
        </div>
      </div>
    </nav>

    <div class="content mt-5 pt-4">
      <router-view />
    </div>
  </div>
</template>

<script>
import { mapActions, mapGetters } from "vuex";
import AlertBox from "./Alert.vue";

export default {
  name: "App",
  components: {
    AlertBox,
  },
  computed: {
    ...mapGetters("sessionManager", ["isLoggedIn"]),
  },
  methods: {
    ...mapActions("sessionManager", ["logoutUser"]),
    logout() {
      this.logoutUser();
      this.$router.push({ name: "Login" });
    },
  },
};
</script>
<style lang=""></style>
