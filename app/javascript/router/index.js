import { createRouter, createWebHistory } from "vue-router";
import Home from "../components/reports/Reports.vue";
import Login from "../components/session/Login.vue";
import MembersList from "../components/members/List.vue";
import MemberForm from "../components/members/Form.vue";
import TeamsList from "../components/teams/List.vue";
import TeamForm from "../components/teams/Form.vue";
import TeamMembers from "../components/teams/Members.vue";
import EventsList from "../components/events/List.vue";
import EventForm from "../components/events/Form.vue";
import EventMembers from "../components/events/Members.vue";
import UserProfile from "../components/users/Page.vue";
import store from "@/store";

const routes = [
  { path: "/", name: "Home", component: Home },
  { path: "/login", name: "Login", component: Login },
  { path: "/profile", name: "UserProfile", component: UserProfile },

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
    path: "/members/:id",
    name: "MemberEdit",
    component: MemberForm,
    props: true,
  },

  // TIMES
  {
    path: "/teams",
    name: "TeamsList",
    component: TeamsList,
  },
  {
    path: "/teams/new",
    name: "TeamCreate",
    component: TeamForm,
  },
  {
    path: "/teams/:id",
    name: "TeamEdit",
    component: TeamForm,
    props: true,
  },
  {
    path: "/teams/:id/members",
    name: "TeamMembers",
    component: TeamMembers,
    props: true,
  },

  // EVENTOS
  {
    path: "/events",
    name: "EventsList",
    component: EventsList,
  },
  {
    path: "/events/new",
    name: "EventCreate",
    component: EventForm,
  },
  {
    path: "/events/:id",
    name: "EventEdit",
    component: EventForm,
    props: true,
  },
  {
    path: "/events/:id/members",
    name: "EventMembers",
    component: EventMembers,
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
