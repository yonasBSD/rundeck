%{--
  - Copyright 2016 SimplifyOps, Inc. (http://simplifyops.com)
  -
  - Licensed under the Apache License, Version 2.0 (the "License");
  - you may not use this file except in compliance with the License.
  - You may obtain a copy of the License at
  -
  -     http://www.apache.org/licenses/LICENSE-2.0
  -
  - Unless required by applicable law or agreed to in writing, software
  - distributed under the License is distributed on an "AS IS" BASIS,
  - WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
  - See the License for the specific language governing permissions and
  - limitations under the License.
  --}%

<%--
  Created by IntelliJ IDEA.
  User: greg
  Date: 4/30/15
  Time: 3:29 PM
--%>

<%@ page import="com.dtolabs.rundeck.core.plugins.configuration.PropertyScope" contentType="text/html;charset=UTF-8" %></page>
<html>
<head>
    <meta http-equiv="Content-Type" content="text/html; charset=UTF-8"/>
    <meta name="tabpage" content="configure"/>
    <meta name="layout" content="base"/>
    <g:set var="projectLabel" value="${session.frameworkLabels?session.frameworkLabels[params.project]:params.project}"/>
    <title><g:appTitle/> - <g:message code="scmController.page.commit.title" args="[projectLabel]"/></title>

</head>

<body>
<div class="content">
<div id="layoutBody">
<div class="row">
    <div class="col-sm-12">
        <g:render template="/common/messages"/>
    </div>
</div>

<div class="row">
    <div class="col-sm-12 ">
    <div class="card">
        <g:form action="performActionSubmit"
                params="${[project: params.project, integration: integration]}"
                useToken="true"
                method="post" class="form form-horizontal">
            <g:hiddenField name="allJobs" value="${params.allJobs}"/>
            <g:hiddenField name="actionId" value="${params.actionId}"/>
            <g:set var="serviceName" value="${integration=='export'?'ScmExport':'ScmImport'}"/>
            <div class="panel" id="createform" style="margin-bottom: 0;">
                <div class="panel-heading">
                    <span class="h3">

                        <stepplugin:message
                                service="${serviceName}"
                                name="${pluginDescription.name}"
                                code="plugin.title"
                                default="${pluginDescription.description?.title?:pluginDescription.name}"/>:
                        <g:if test="${actionView && actionView.title}">
                            <stepplugin:message
                                    service="${serviceName}"
                                    name="${pluginDescription.name}"
                                    code="action.${actionId}.title"
                                    default="${actionView.title}"/>
                        </g:if>
                        <g:else>
                            <g:message code="scmController.page.commit.description" default="SCM Export"/>
                        </g:else>
                    </span>
                </div>

                <div class="list-group">
                    <g:if test="${actionView && actionView.description}">
                        <div class="list-group-item">
                            <div class="list-group-item-text">
                                <g:markdown><stepplugin:message
                                        service="${serviceName}"
                                        name="${pluginDescription.name}"
                                        code="action.${actionId}.description"
                                        default="${actionView.description}"/></g:markdown>
                            </div>
                        </div>
                    </g:if>
                    <g:if test="${integration == 'export'}">

                        <g:if test="${jobs || deletedPaths}">

                            <div class="list-group-item">
                                <div class="row">
                                    <div class="col-sm-12">
                                        <div class="help-block">
                                            <g:message code="select.jobs.to.export"/>
                                        </div>
                                    </div>
                                </div>
                            </div>

                        </g:if>
                        <g:if test="${jobs}">

                            <div class="list-group-item">
                                <div class="form-group">
                                    <g:each in="${jobs}" var="job">
                                        <div class="flex justify-start items-center" style="margin-bottom:10px;">
                                            <g:set var="jobstatus" value="${scmStatus?.get(job.extid)}"/>
                                            <div class="checkbox flex-none" style="margin-top: 0;margin-left: 20px;">
                                                    <g:if test="${jobstatus?.synchState?.toString() != 'CLEAN'}">

                                                        <g:checkBox name="id" value="${job.extid}"
                                                                    id="id${job.extid}"
                                                                    checked="${selected?.contains(job.extid)}"/>
                                                    </g:if>
                                                <label for="id${job.extid}">
                                                    <g:render template="statusIcon"
                                                            model="[iscommit          : true,
                                                                    exportStatus: jobstatus?.synchState?.toString(),
                                                                    notext: true,
                                                                    integration:integration,
                                                                    text: '',
                                                                    commit: jobstatus?.commit]"/>
                                                    <g:render template="statusIcon"
                                                            model="[iscommit          : true,
                                                                    exportStatus: jobstatus?.synchState?.toString(),
                                                                    noicon: true,
                                                                    integration:integration,
                                                                    text: job.jobName,
                                                                    commit: jobstatus?.commit]"/>

                                                    <span class="text-strong">
                                                        - ${job.groupPath}
                                                    </span>

                                                </label>
                                                <g:link action="diff" class="btn btn-xs btn-info"
                                                        params="${[project: params.project, id: job.extid, integration: 'export']}">
                                                    <g:message code="button.View.Diff.title"/>
                                                </g:link>
                                            </div>
                                            <div class="" style="margin-left: 20px;">
                                                <g:if test="${renamedJobPaths?.get(job.extid)}">
                                                    <div class="">
                                                        <span class="text-strong">
                                                            <g:icon name="file"/>
                                                            ${renamedJobPaths[job.extid]}

                                                            <g:hiddenField
                                                                    name="renamedPaths.${job.extid}"
                                                                    value="${renamedJobPaths[job.extid]}"/>
                                                        </span>
                                                    </div>
                                                </g:if>
                                                <g:if test="${filesMap?.get(job.extid)}">
                                                    <div class="">
                                                        <span class="text-strong">
                                                            <g:if test="${renamedJobPaths?.get(job.extid)}">
                                                                <g:icon name="arrow-right"/>
                                                            </g:if>
                                                            <g:icon name="file"/>
                                                            ${filesMap[job.extid]}

                                                        </span>
                                                    </div>
                                                </g:if>
                                            </div>
                                        </div>
                                    </g:each>
                                </div>
                                <g:if test="${jobs.size() > 1}">
                                    <div class=" row row-spacing">
                                        <div class=" col-sm-12">
                                            <span class="btn btn-simple btn-hover"
                                                  onclick="jQuery('input[name=id]').prop('checked', true)">
                                                <g:message code="select.all"/>
                                            </span>
                                        &bull;
                                            <span class="btn btn-simple btn-hover"
                                                  onclick="jQuery('input[name=id]').prop('checked', false)">
                                                <g:message code="select.none"/>
                                            </span>
                                        </div>
                                    </div>
                                </g:if>
                            </div>

                        </g:if>
                        <g:if test="${deletedPaths}">

                            <div class="list-group-item">
                                <div class="form-group">
                                    <g:each in="${deletedPaths.keySet().sort()}" var="path" status="counter">
                                        <div class="flex justify-start items-center" style="margin-bottom:10px;">
                                            <div class="checkbox flex-none" style="margin-top: 0;margin-left: 20px;">
                                                <g:checkBox name="deletePaths" value="${path}"
                                                            id="deletePaths${counter}"
                                                            checked="${selectedPaths?.contains(path)}"/>
                                                <label for="deletePaths${counter}">
                                                    <g:set var="deletedJobText"
                                                           value="${ deletedPaths[path].jobNameAndGroup ?: message(code: "deleted.job.label")}"/>

                                                    <g:render template="statusIcon"
                                                              model="[iscommit: true, exportStatus: 'DELETED', notext: true,
                                                                                                         text: '',]"/>
                                                    <g:render template="statusIcon"
                                                              model="[iscommit: true, exportStatus: 'DELETED', noicon: true,
                                                                                                         text: deletedJobText]"/>

                                                </label>
                                            </div>

                                            <div class="flex justify-center items-center" style="margin-left: 20px;">
                                                <span class="text-strong">
                                                    <span class="glyphicon glyphicon-file"></span>
                                                    ${path}
                                                </span>
                                            </div>
                                        </div>

                                    </g:each>
                                </div>
                                <g:if test="${deletedPaths.size() > 1}">
                                    <div class=" row row-spacing">
                                        <div class=" col-sm-12">
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=deletePaths]').prop('checked', true)">
                                                <g:message code="select.all"/>
                                            </span>
                                        &bull;
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=deletePaths]').prop('checked', false)">
                                                <g:message code="select.none"/>
                                            </span>
                                        </div>
                                    </div>
                                </g:if>
                            </div>
                        </g:if>
                        <g:if test="${!jobs && !deletedPaths && scmProjectStatus.state.toString() == 'CLEAN'}">
                            <div class="list-group-item">
                                <g:message code="no.changes" />
                            </div>
                        </g:if>
                    </g:if>
                    <g:elseif test="${integration == 'import'}">
                        <g:if test="${trackingItems}">

                            <div class="list-group-item overflowy">
                                <div class="form-group">
                                    <g:each in="${trackingItems}" var="trackedItem">
                                        <div class="flex justify-start items-center" style="margin-bottom:10px;">
                                        <g:set var="job" value="${trackedItem.jobId?jobMap[trackedItem.jobId]:null}"/>
                                        <div class="checkbox flex-none"  style="margin-top: 0;margin-left: 20px;">
                                                <g:checkBox name="chosenTrackedItem"
                                                            id="chosenTrackedItem${trackedItem.id}"
                                                            value="${enc(attr:trackedItem.id)}"
                                                            checked="${selectedItems?.contains(trackedItem.id)||trackedItem.selected||(trackedItem.jobId && selected?.contains(trackedItem.jobId))}"/>
                                            <label title="${trackedItem.id}" for="chosenTrackedItem${trackedItem.id}">
                                                <g:if test="${job}">

                                                    <g:set var="jobstatus" value="${scmStatus?.get(job.extid)}"/>

                                                    <g:render template="statusIcon"
                                                              model="[iscommit          : true,
                                                                      importStatus: jobstatus?.synchState?.toString(),
                                                                      notext: true,
                                                                      integration:integration,
                                                                      text: '',
                                                                      commit: jobstatus?.commit]"/>
                                                    <g:render template="statusIcon"
                                                              model="[iscommit          : true,
                                                                      importStatus: jobstatus?.synchState?.toString(),
                                                                      noicon: true,
                                                                      integration:integration,
                                                                      text: job.jobName,
                                                                      commit: jobstatus?.commit]"/>

                                                    <span class="text-strong">
                                                        - ${job.groupPath}
                                                    </span>
                                                </g:if>
                                                <g:else>

                                                    <span class="">
                                                        <g:if test="${trackedItem.iconName}">
                                                            <g:icon name="${trackedItem.iconName}"/>
                                                        </g:if>
                                                        ${trackedItem.title ?: trackedItem.id}
                                                    </span>
                                                </g:else>

                                            </label>
                                            <g:if test="${job}">

                                                <g:link action="diff" class="btn btn-xs btn-info"
                                                        params="${[project: params.project, id: job.extid, integration: 'import']}">
                                                    <g:message code="button.View.Diff.title"/>
                                                </g:link>
                                            </g:if>
                                        </div>
                                        <g:if test="${job}">
                                            <div class="col-sm-11 col-sm-offset-1">
                                                <span class="text-strong">
                                                    <span class="">
                                                        <g:if test="${trackedItem.iconName}">
                                                            <g:icon name="${trackedItem.iconName}"/>
                                                        </g:if>
                                                        ${trackedItem.title ?: trackedItem.id}
                                                    </span>
                                                </span>
                                            </div>
                                        </g:if>

                                        </div>
                                    </g:each>
                                </div>
                                <g:if test="${trackingItems.size() > 1}">
                                    <div class=" row row-spacing">
                                        <div class=" col-sm-12">
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=chosenTrackedItem]').prop('checked', true)">
                                                <g:message code="select.all"/>
                                            </span>
                                        &bull;
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=chosenTrackedItem]').prop('checked', false)">
                                                <g:message code="select.none"/>
                                            </span>
                                        </div>
                                    </div>
                                </g:if>
                            </div>
                        </g:if>
                        <g:if test="${toDeleteItems}">
                            <div class="list-group-item overflowy">
                                <div class="form-group">
                                    <g:each in="${toDeleteItems}" var="toDeleteItem">
                                        <div class="flex justify-start items-center" style="margin-bottom:10px;">
                                        <g:set var="job" value="${toDeleteItem.jobId?jobMap[toDeleteItem.jobId]:null}"/>
                                        <g:set var="jobst" value="${job?scmStatus?.get(job.extid)?.synchState?.toString():null}"/>

                                        <div class="checkbox flex-none" style="margin-top: 0;margin-left: 20px;">

                                                <g:checkBox name="chosenDeleteItem"
                                                    id="chosenDeleteItem${toDeleteItem.id}"
                                                            value="${(jobst == 'DELETE_NEEDED')?toDeleteItem.jobId:toDeleteItem.id}"
                                                            checked="${selectedItems?.contains(toDeleteItem.id)||toDeleteItem.selected||(toDeleteItem.jobId && selected?.contains(toDeleteItem.jobId))}"/>
                                            <label title="${toDeleteItem.id}" for="chosenDeleteItem${toDeleteItem.id}">
                                                <g:if test="${job}">

                                                    <g:set var="jobstatus" value="${scmStatus?.get(job.extid)}"/>

                                                    <g:render template="statusIcon"
                                                              model="[iscommit          : true,
                                                                      importStatus: jobstatus?.synchState?.toString(),
                                                                      notext: true,
                                                                      integration:integration,
                                                                      text: '',
                                                                      commit: jobstatus?.commit]"/>
                                                    <g:render template="statusIcon"
                                                              model="[iscommit          : true,
                                                                      importStatus: jobstatus?.synchState?.toString(),
                                                                      noicon: true,
                                                                      integration:integration,
                                                                      text: job.jobName,
                                                                      commit: jobstatus?.commit]"/>

                                                    <span class="text-strong">
                                                        - ${job.groupPath}
                                                    </span>
                                                </g:if>
                                                <g:else>

                                                    <span class="">
                                                        <g:if test="${toDeleteItem.iconName}">
                                                            <g:icon name="${toDeleteItem.iconName}"/>
                                                        </g:if>
                                                        ${toDeleteItem.title ?: toDeleteItem.id}
                                                    </span>
                                                </g:else>

                                            </label>
                                            <g:if test="${job}">

                                                <g:link action="diff" class="btn btn-xs btn-info"
                                                        params="${[project: params.project, id: job.extid, integration: 'import']}">
                                                    <g:message code="button.View.Diff.title"/>
                                                </g:link>
                                            </g:if>
                                        </div>
                                        <g:if test="${job}">
                                            <div class="col-sm-11 col-sm-offset-1">
                                                <span class="text-strong">
                                                    <span class="">
                                                        <g:if test="${toDeleteItem.iconName}">
                                                            <g:icon name="${toDeleteItem.iconName}"/>
                                                        </g:if>
                                                        ${toDeleteItem.title ?: toDeleteItem.id}
                                                    </span>
                                                </span>
                                            </div>
                                        </g:if>
                                        </div>
                                    </g:each>
                                </div>
                                <g:if test="${toDeleteItems.size() > 1}">
                                    <div class=" row row-spacing">
                                        <div class=" col-sm-12">
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=chosenDeleteItem]').prop('checked', true)">
                                                <g:message code="select.all"/>
                                            </span>
                                            &bull;
                                            <span class="btn btn-default"
                                                  onclick="jQuery('input[name=chosenDeleteItem]').prop('checked', false)">
                                                <g:message code="select.none"/>
                                            </span>
                                        </div>
                                    </div>
                                </g:if>
                            </div>
                        </g:if>
                    </g:elseif>
                    <div class="list-group-item">
                        <g:if test="${actionView?.properties}">
                            <g:render template="/framework/pluginConfigPropertiesInputs" model="${[
                                    service:serviceName,
                                    provider:pluginDescription.name,
                                    messagePrefix:"action.${actionId}.",
                                    properties:actionView?.properties,
                                    report:report,
                                    values:config,
                                    fieldnamePrefix:'pluginProperties.',
                                    origfieldnamePrefix:'orig.' ,
                                    allowedScope: PropertyScope.Project
                            ]}"/>
                        </g:if>
                    </div>
                </div>

                <div class="panel-heading">
                    <button class="btn btn-default" name="cancel" value="Cancel"><g:message
                            code="button.action.Cancel"/></button>
                    <g:submitButton
                            name="submit"
                            value="${stepplugin.messageText(service:serviceName,name:pluginDescription.name,code:'action.'+actionId+'.buttonTitle',default:actionView.buttonTitle ?:
                                    g.message(code: 'button.Export.title'))}"
                            class="btn btn-cta"/>
                </div>
            </div>
        </g:form>
    </div>
    </div>
</div>
</div>
</div>
</body>
</html>
