/*
 * Copyright 2016 SimplifyOps, Inc. (http://simplifyops.com)
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

package com.dtolabs.rundeck.plugins.scm;

import com.dtolabs.rundeck.core.plugins.views.Action;

import java.util.List;

/**
 * Created by greg on 9/14/15.
 */
public interface JobImportState {
    /**
     * Get the state of the job for import
     * @return state
     */
    ImportSynchState getSynchState();

    /**
     * @return the last imported commit info if available
     */
    ScmCommitInfo getCommit();

    /**
     * @return Actions available
     */
    List<Action> getActions();

    default JobRenamed getJobRenamed(){
        return null;
    }
}
