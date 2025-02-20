<template>
  <div>
    <div class="row">
      <div class="col-xs-12 col-sm-12" style="padding-bottom: 10px">
        <h3 style="margin: 0px">Plugin Repositories</h3>
      </div>
      <div class="col-xs-12 col-sm-6">
        <form @submit.prevent="search">
          <div class="input-group input-group-sm">
            <input
              v-model="searchString"
              type="text"
              class="form-control"
              placeholder="Search for..."
            />
            <span v-if="searchResults.length > 0" class="input-group-btn">
              <button
                class="btn btn-default btn-fill"
                type="button"
                @click="clearSearch"
              >
                <i class="fas fa-times"></i>
              </button>
            </span>
            <span v-else class="input-group-btn">
              <button
                class="btn btn-default btn-fill"
                type="button"
                @click="search"
              >
                <i class="fas fa-search"></i>
              </button>
            </span>
          </div>
        </form>
      </div>
      <div class="col-xs-12 col-sm-6 text-right">
        <div
          class="btn-group btn-group-sm btn-group-justified squareish-buttons"
          role="group"
          aria-label="..."
        >
          <a
            class="btn btn-default"
            :class="{ active: showWhichPlugins === true }"
            :disabled="searchResults.length > 0"
            @click="showWhichPlugins = true"
            >Installed</a
          >
          <a
            class="btn btn-default"
            :class="{ active: showWhichPlugins === null }"
            :disabled="searchResults.length > 0"
            @click="showWhichPlugins = null"
            >All</a
          >
          <a
            class="btn btn-default"
            :class="{ active: showWhichPlugins === false }"
            :disabled="searchResults.length > 0"
            @click="showWhichPlugins = false"
            >Not Installed</a
          >
        </div>
      </div>
    </div>
    <div v-show="searchResults.length > 0" class="row">
      <h3
        class="col-xs-12"
        style="margin: 1em 0 0; font-weight: bold; text-transform: uppercase"
      >
        Search Results
      </h3>
      <div
        v-for="repo in searchResults"
        :key="repo.repositoryName"
        class="col-xs-12"
      >
        <RepositoryRow :repo="repo" type="search" />
      </div>
    </div>
    <div v-if="searchResults.length === 0" class="row">
      <div
        v-for="repo in repositories"
        :key="repo.repositoryName"
        class="col-xs-12"
      >
        <RepositoryRow :repo="repo" />
      </div>
    </div>
  </div>
</template>

<script>
import { defineComponent } from "vue";
import _ from "lodash";
import axios from "axios";
import Fuse from "fuse.js";
import RepositoryRow from "../components/Repository.vue";
import { mapState, mapActions } from "vuex";
import { getRundeckContext } from "@/library";

const FuseSearchOptions = {
  shouldSort: true,
  threshold: 0.2,
  location: 0,
  // distance: 100,
  // maxPatternLength: 32,
  minMatchCharLength: 1,
  keys: ["display", "name", "title"],
};

export default defineComponent({
  name: "PluginRepositoryView",
  components: {
    RepositoryRow,
  },
  computed: {
    ...mapState("repositories", ["repositories"]),
  },
  data() {
    return {
      showWhichPlugins: null,
      searchString: "",
      searchIndex: [],
      searchResults: [],
      loggingPermissionCheck: false,
    };
  },
  watch: {
    showWhichPlugins: function (newVal, oldVal) {
      this.setInstallStatusOfPluginsVisibility(newVal);
    },
  },
  methods: {
    ...mapActions("repositories", [
      "initData",
      "setInstallStatusOfPluginsVisibility",
    ]),
    ...mapActions("overlay", ["openOverlay"]),
    clearSearch() {
      this.searchResults = [];
    },
    search() {
      this.clearSearch();
      this.showWhichPlugins = null;
      if (this.searchString === "") {
        this.searchResults = [];
        return;
      }
      for (let index = 0; index < this.repositories.length; index++) {
        const theRepo = this.repositories[index].results;
        const fuse = new Fuse(theRepo, FuseSearchOptions);
        const results = fuse
          .search(this.searchString)
          .map((result) => result.item);
        if (
          !window.repositoryLocalSearchOnly &&
          this.repositories[index].repositoryName === "official"
        ) {
          let versionNumber = null;
          const mappedResults = _.map(results, "id");
          const rundeckVersionNumberContainer = document.getElementsByClassName(
            "rundeck-version-identity",
          );
          if (
            rundeckVersionNumberContainer[0] &&
            rundeckVersionNumberContainer[0].dataset &&
            rundeckVersionNumberContainer[0].dataset.versionString
          ) {
            versionNumber =
              rundeckVersionNumberContainer[0].dataset.versionString;
          }
          const payload = {
            searchString: this.searchString,
            results: mappedResults,
            rundeckVer: versionNumber,
          };
          const appRundeckGatewayUrl =
            getRundeckContext().appMeta.appRundeckGatewayUrl;

          axios({
            method: "post",
            url: `${appRundeckGatewayUrl}/repo/v1/oss/search/save`,
            data: payload,
          });
        }

        this.searchResults.push({
          repositoryName: this.repositories[index].repositoryName,
          results: results,
        });
      }
    },
  },
  mounted() {
    this.initData().then(
      () => {
        // don't do anything. everything is good!
      },
      (error) => {
        this.$alert({
          title: "Error Accessing Plugins",
          content:
            "Plugins may not be an active feature in your Rundeck install.",
        });
        this.openOverlay(false);
      },
    );
  },
});
</script>
<style lang="scss" scoped>
// Search Input
.input-group .form-control {
  border: 2px solid #66615b;
}
// .input-group-btn .btn-default:not(.btn-fill) {
// }
</style>

<style lang="scss" scoped>
.btn-group.btn-group.squareish-buttons {
  .btn {
    border-width: 2px;
  }
}
.btn-group.squareish-buttons
  > .btn:first-child:not(:last-child):not(.dropdown-toggle) {
  border-top-left-radius: 6px;
  border-bottom-left-radius: 6px;
}
.btn-group.squareish-buttons > .btn:last-child:not(:first-child),
.btn-group > .dropdown-toggle:not(:first-child) {
  border-top-right-radius: 6px;
  border-bottom-right-radius: 6px;
}
.btn-group.squareish-buttons > .btn:active,
.btn-group.squareish-buttons > .btn:visited,
.btn-group.squareish-buttons > .btn:hover,
.btn-group.squareish-buttons > .btn:focus,
.btn-group.squareish-buttons > .btn:focus-within,
.btn-group.squareish-buttons > .btn.active:disabled {
  background-color: #66615b;
  color: rgba(255, 255, 255, 0.85);
  border-color: #66615b;
}
.support-filters {
  background: black;
  color: white;
  padding: 2em 1em;
  font-size: 20px;
  .title {
    color: #cdcdcd;
    display: flex;
    // align-items: center;
    font-size: 1.8rem;
    padding: 1em 2em;
    text-transform: uppercase;
    letter-spacing: 3.44px;
  }
  label {
    border: 1px solid blue;
    padding: 1em 2em;
    input[type="checkbox"] {
      display: none;
    }
  }
  :checked + label {
    font-weight: bold;
    border: 1px solid red;
  }
}
</style>
