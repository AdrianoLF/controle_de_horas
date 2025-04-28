<template>
  <canvas id="planet-chart" />
</template>

<script>
import { Chart, registerables } from "chart.js";

export default {
  name: "PlanetChart",
  data() {
    return {};
  },
  props: {
    chartData: {
      type: Object,
      default: () => {},
    },
  },
  computed: {},
  mounted() {
    Chart.register(...registerables);

    const ctx = document.getElementById("planet-chart").getContext("2d");

    const chartOptions = {
      responsive: true,
      plugins: {
        legend: {
          display: false,
        },
        title: {
          display: true,
          text: "Distribuição de Funcionários por Faixa Salarial",
        },
      },
      scales: {
        y: {
          beginAtZero: true,
          title: {
            display: true,
            text: "Número de Funcionários",
          },
        },
        x: {
          title: {
            display: true,
            text: "Faixas Salariais",
          },
        },
      },
    };

    new Chart(ctx, {
      type: "bar",
      data: this.chartData,
      options: chartOptions,
    });
  },
  methods: {},
};
</script>

<style scoped></style>
