import { createRouter, createWebHistory } from "vue-router";
import Home from "../components/reports/Reports.vue";
import ProponentCreateForm from "../components/proponents/CreateForm.vue";
import Login from "../components/session/Login.vue";
import ProponentEditForm from "../components/proponents/EditForm.vue";
import store from "@/store";

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/login", name: "Login", component: Login },
  {
    path: "/proponents/new",
    name: "ProponentCreate",
    component: ProponentCreateForm,
  },
  {
    path: "/proponents/edit/:id",
    name: "ProponentEdit",
    component: ProponentEditForm,
    props: true,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  if (!store.getters["sessionManager/isLoggedIn"] && to.name !== "Login") {
    next({ name: "Login" });
  } else {
    next();
  }
});

export default router;
