import { createRouter, createWebHistory } from "vue-router";
import Home from "../components/reports/Reports.vue";
import Login from "../components/session/Login.vue";
import MembersList from "../components/members/List.vue";
import TeamsList from "../components/teams/List.vue";
import EventsList from "../components/events/List.vue";
import UserProfile from "../components/users/Page.vue";
import UsersList from "../components/users/List.vue";
import PublicReports from "../components/reports/PublicReports.vue";
import store from "@/store";

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/login", name: "Login", component: Login },
  { path: "/profile", name: "UserProfile", component: UserProfile },
  {
    path: "/public/reports/:ra",
    name: "PublicReports",
    component: PublicReports,
    meta: { isPublic: true },
  },

  // USUÁRIOS
  {
    path: "/users",
    name: "UsersList",
    component: UsersList,
    meta: { requiresSuperAdmin: true },
  },

  // MEMBROS
  {
    path: "/members",
    name: "MembersList",
    component: MembersList,
    meta: { requiresSuperAdmin: true },
  },
  // TIMES
  {
    path: "/teams",
    name: "TeamsList",
    component: TeamsList,
    meta: { requiresSuperAdmin: true },
  },

  // EVENTOS
  {
    path: "/events",
    name: "EventsList",
    component: EventsList,
  },
];

const router = createRouter({
  history: createWebHistory(),
  routes,
});

router.beforeEach((to, from, next) => {
  if (
    !store.getters["sessionManager/isLoggedIn"] &&
    to.name !== "Login" &&
    !to.meta.isPublic
  ) {
    next({ name: "Login" });
  } else {
    // Redireciona usuários não-super-admin da Home para Eventos
    if (to.name === "Home" && !store.getters["sessionManager/isSuperAdmin"]) {
      next({ name: "EventsList" });
    } else if (
      to.meta.requiresSuperAdmin &&
      !store.getters["sessionManager/isSuperAdmin"]
    ) {
      next({ name: "Home" });
    } else {
      next();
    }
  }
});

export default router;
