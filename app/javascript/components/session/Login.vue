<template>
  <div class="container mt-5">
    <h1 class="text-center mb-4">Faça login ou se registre</h1>
    <div class="card p-4 shadow">
      <div v-if="isLoggedIn">
        <div class="d-flex justify-content-end mb-3">
          <button @click="logoutUser" class="btn btn-danger">Logout</button>
        </div>
        <table class="table table-striped">
          <thead class="thead-dark">
            <tr>
              <th scope="col">ID</th>
              <th scope="col">Email</th>
              <th scope="col">Token</th>
            </tr>
          </thead>
          <tbody>
            <tr>
              <th scope="row">{{ getUserID }}</th>
              <td>{{ getUserEmail }}</td>
              <td>{{ getAuthToken }}</td>
            </tr>
          </tbody>
        </table>
      </div>
      <div v-else>
        <div class="row">
          <!-- Formulário de Login -->
          <div class="col-md-6 mb-4">
            <h3 class="mb-3">Login</h3>
            <form @submit.prevent="onLogin">
              <div class="form-group">
                <label for="loginEmail">Email</label>
                <input
                  type="email"
                  id="loginEmail"
                  v-model="loginEmail"
                  class="form-control"
                  placeholder="Digite seu email"
                  required
                />
              </div>
              <div class="form-group">
                <label for="loginPassword">Senha</label>
                <input
                  type="password"
                  id="loginPassword"
                  v-model="loginPassword"
                  class="form-control"
                  placeholder="Digite sua senha"
                  required
                />
              </div>
              <button type="submit.prevent" class="btn btn-primary">Login</button>
              <span v-if="loginError" class="text-danger ml-2">{{
                loginError
              }}</span>
            </form>
          </div>
          <!-- Formulário de Cadastro -->
          <div class="col-md-6 mb-4">
            <h3 class="mb-3">Registrar-se</h3>
            <form @submit.prevent="onSignUp">
              <div class="form-group">
                <label for="signUpEmail">Email</label>
                <input
                  type="email"
                  id="signUpEmail"
                  v-model="signUpEmail"
                  class="form-control"
                  placeholder="Digite seu email"
                  required
                />
              </div>
              <div class="form-group">
                <label for="signUpPassword">Senha</label>
                <input
                  type="password"
                  id="signUpPassword"
                  v-model="signUpPassword"
                  class="form-control"
                  placeholder="Digite sua senha"
                  required
                />
              </div>
              <button type="submit.prevent" class="btn btn-success">Registrar</button>
              <span v-if="signUpError" class="text-danger ml-2">{{
                signUpError
              }}</span>
            </form>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import "@/store/index.js";
import { mapActions, mapGetters } from "vuex";

export default {
  name: "SessionManager",
  computed: {
    ...mapGetters("sessionManager", [
      "getAuthToken",
      "getUserEmail",
      "getUserID",
      "isLoggedIn",
    ]),
  },
  data() {
    return {
      signUpEmail: "",
      signUpPassword: "",
      loginEmail: "",
      loginPassword: "",
      loginError: "",
      signUpError: "",
    };
  },
  watch: {
    isLoggedIn(newVal) {
      if (newVal) this.$router.push({ name: "Home" });
    },
  },
  methods: {
    ...mapActions("sessionManager", [
      "registerUser",
      "loginUser",
      "logoutUser",
    ]),
    async onSignUp(event) {
      event.preventDefault();
      let data = {
        user: {
          email: this.signUpEmail,
          password: this.signUpPassword,
        },
      };
      try {
        await this.registerUser(data);
        this.resetData();
      } catch (error) {
        this.signUpError = "Erro ao registrar o usuário.";
      }
    },
    async onLogin(event) {
      event.preventDefault();
      let data = {
        user: {
          email: this.loginEmail,
          password: this.loginPassword,
        },
      };
      try {
        await this.loginUser(data);
        this.resetData();
      } catch (error) {
        this.loginError = "Erro ao fazer login.";
      }
    },
    resetData() {
      this.signUpEmail = "";
      this.signUpPassword = "";
      this.loginEmail = "";
      this.loginPassword = "";
      this.loginError = "";
      this.signUpError = "";
    },
  },
};
</script>

<style scoped>
/* Estilos adicionais podem ser adicionados aqui se necessário */
</style>
