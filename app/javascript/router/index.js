import { createRouter, createWebHistory } from "vue-router";
import Home from "../components/reports/Reports.vue";
import ProponentCreateForm from "../components/proponents/CreateForm.vue";
import Login from "../components/session/Login.vue";
import ProponentEditForm from "../components/proponents/EditForm.vue";
import MembersList from "../components/members/List.vue";
import MemberForm from "../components/members/Form.vue";
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

  // MEMBROS
  {
    path: "/members",
    name: "MembersList",
    component: MembersList,
  },
  {
    path: "/members/new",
    name: "MemberCreate",
    component: MemberForm,
  },
  {
    path: "/members/edit/:id",
    name: "MemberEdit",
    component: MemberForm,
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
