<template>
  <div>
    <schedule-editor
      v-if="updatedData"
      v-model="updatedData"
      :event-bus="eventBus"
      :use-crontab-string="useCrontabString"
    />
    <json-embed :output-data="outputData" field-name="schedulesJsonData" />
  </div>
</template>

<script lang="ts">
import ScheduleEditor from "../../../components/job/schedule/ScheduleEditor.vue";
import JsonEmbed from "./JsonEmbed.vue";

import { getRundeckContext } from "../../../../library";

export default {
  name: "App",
  components: {
    ScheduleEditor,
    JsonEmbed,
  },
  props: ["eventBus", "useCrontabString"],
  data() {
    return {
      project: null,
      rdBase: null,
      schedulesData: {},
      updatedData: null,
      outputData: {},
    };
  },
  watch: {
    updatedData: {
      handler() {
        this.eventBus.emit("job-edit-schedules-changed", this.updatedData);
        const { timeZones, ...other } = this.updatedData;
        this.outputData = other;
        this.eventBus.emit("jobedit.page.confirm", true);
      },
      deep: true,
    },
  },
  async mounted() {
    const rundeck = getRundeckContext();
    if (rundeck && rundeck.rdBase && rundeck.projectName) {
      this.rdBase = rundeck.rdBase;
      this.project = rundeck.projectName;
      if (rundeck && rundeck.data) {
        this.schedulesData = rundeck.data.schedulesData;
        this.updatedData = Object.assign({}, this.schedulesData);
        const { timeZones, ...other } = this.updatedData;
        this.outputData = other;
      }
    }
  },
};
</script>

<style></style>
