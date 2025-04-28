<template lang="">

    <proponent-form />
    <div style="height: 50px" />
  </div>
</template>
<script>
import ProponentForm from "./proponents/CreateForm.vue";

export default {
  name: "Home",
  components: { ProponentForm },
  data() {
    return {
      proponents: [],
    };
  },
  mounted() {
    this.subscribeToNotifications();
  },
  methods: {},
};
</script>
<style lang=""></style>
