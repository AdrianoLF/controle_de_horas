<template>
  <div>
    <div class="container">
      <h2 class="mb-4">Distribuição / Faixa salarial</h2>
      <div class="card p-3">
        <span v-if="isLoadingReport">Carregando...</span>
        <proponents-chart v-else :chart-data="chartData" />
      </div>
      <div class="custom-legend mt-3">
        <h5>Faixas Salariais</h5>
        <ul class="list-group list-group-horizontal flex-wrap">
          <li
            v-for="faixa in faixas"
            :key="faixa.label"
            class="list-group-item border-0 p-1 d-flex align-items-center"
          >
            <span
              class="legend-color me-2 rounded"
              :style="{ backgroundColor: faixa.backgroundColor }"
            ></span>
            <small>
              <strong>{{ faixa.label }}:</strong>
              {{ faixa.descricao }}
            </small>
          </li>
        </ul>
      </div>
    </div>

    <proponents-list />
  </div>
</template>

<script>
import { getProponentsReport } from "@/api/proponents";
import { mapGetters } from "vuex";
import ProponentsList from "./List.vue";
import ProponentsChart from "./Chart.vue";
import ActionCableApp from "@/helper/actionCable.js";

export default {
  data() {
    return {
      contagemTotal: 0,
      primeiraFaixa: 0,
      segundaFaixa: 0,
      terceiraFaixa: 0,
      quartaFaixa: 0,
      isLoadingReport: true,
      lastMessageReceivedTime: 0,
    };
  },
  components: {
    ProponentsList,
    ProponentsChart,
  },
  mounted() {
    this.subscribeToNotifications();
    this.fetchReport();
  },
  computed: {
    ...mapGetters("sessionManager", ["getAuthToken"]),
    chartData() {
      return {
        labels: this.faixas.map((faixa) => faixa.label),
        datasets: [
          {
            label: "Funcionários por faixa",
            data: this.faixas.map((faixa) => faixa.data),
            backgroundColor: this.faixas.map((faixa) => faixa.backgroundColor),
            borderColor: this.faixas.map((faixa) => faixa.borderColor),
            borderWidth: 1,
          },
        ],
      };
    },
    faixas() {
      return [
        {
          label: "Primeira faixa",
          descricao: "Até R$ 1.045,00",
          backgroundColor: "rgba(255, 99, 132, 0.2)",
          borderColor: "rgba(255, 99, 132, 1)",
          data: this.primeiraFaixa,
        },
        {
          label: "Segunda faixa",
          descricao: "De R$ 1.045,01 a R$ 2.089,60",
          backgroundColor: "rgba(54, 162, 235, 0.2)",
          borderColor: "rgba(54, 162, 235, 1)",
          data: this.segundaFaixa,
        },
        {
          label: "Terceira faixa",
          descricao: "De R$ 2.089,61 até R$ 3.134,40",
          backgroundColor: "rgba(255, 206, 86, 0.2)",
          borderColor: "rgba(255, 206, 86, 1)",
          data: this.terceiraFaixa,
        },
        {
          label: "Quarta faixa",
          descricao: "De R$ 3.134,41 até R$ 6.101,06",
          backgroundColor: "rgba(75, 192, 192, 0.2)",
          borderColor: "rgba(75, 192, 192, 1)",
          data: this.quartaFaixa,
        },
      ];
    },
  },
  methods: {
    async fetchReport() {
      this.isLoadingReport = true;
      try {
        const { total_count, group_count } = await getProponentsReport();
        const { first, second, third, fourth } = group_count;

        this.contagemTotal = total_count;
        this.primeiraFaixa = first;
        this.segundaFaixa = second;
        this.terceiraFaixa = third;
        this.quartaFaixa = fourth;
        this.isLoadingReport = false;
      } catch (error) {
        console.error("Erro ao buscar proponentes:", error);
      }
    },
    subscribeToNotifications() {
      ActionCableApp.cable.subscriptions.create(
        { channel: "NotificationsChannel", token: this.getAuthToken },
        {
          received: (data) => {
            if (data?.message === "refresh_proponents") this.fetchReport();
          },
        }
      );
    },
  },
};
</script>
<style scoped>
.custom-legend h5 {
  font-size: 1rem;
  margin-bottom: 0.5rem;
}

.custom-legend ul {
  padding-left: 0;
}

.legend-color {
  display: inline-block;
  width: 15px;
  height: 15px;
  border: 1px solid #000;
}
@media (max-width: 576px) {
  .custom-legend ul {
    flex-direction: column;
  }
  .custom-legend li {
    margin-bottom: 0.5rem;
  }
}
</style>
