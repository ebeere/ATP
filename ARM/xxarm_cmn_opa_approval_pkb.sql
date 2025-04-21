CREATE OR REPLACE PACKAGE BODY xxarm_cmn_opa_approval_pkg AS

  -- +========================================================================================+
-- |                              Oracle Middle East Consulting                             |
-- +========================================================================================+
-- | $Header:$                                                                              |
-- |                                                                                        |
-- | PROGRAM NAME    : XXARM_CMN_OPA_APPROVAL_PKG.pks                                       |
-- |                                                                                        |
-- | DESCRIPTION     : Package Specs to update approval status and get data OPA process     |
-- |                                                                                        |
-- | CAUTION/WARNINGS: Run under ARMINT Schema                                             |
-- |                                                                                        |
-- | HISTORY                                                                                |
-- | =======                                                                                |
-- | Version  Date         Author                   Remarks                                 |
-- | -------  -----------  --------------------     ----------------------------------------|
-- | 1.0      05-Feb-2025  OSI Consulting           Initial Version                         |
-- +========================================================================================+

  -- +=====================================================================+
  -- | Name        : UPDATE_ACTION_APPROVAL_TAB                            |
  -- |                                                                     |
  -- | Description : This procedure is used to update approval status      | 
  -- +=====================================================================+

    PROCEDURE update_action_approval_tab (
        p_opa_processid      IN VARCHAR2,
        p_approval_status    IN VARCHAR2,
        p_user               IN VARCHAR2,
        p_opa_submitted_by   IN VARCHAR2,
        p_process_name       IN VARCHAR2,
        p_business_id        IN VARCHAR2,
        p_comments           IN VARCHAR2,
        p_opa_submitted_date IN VARCHAR2,
        p_last_updated_date  IN VARCHAR2,
        x_return_code        OUT VARCHAR2,
        x_return_message     OUT VARCHAR2
    ) AS

        v_sql          CLOB;
        v_sql_columns  CLOB;
        v_where_sql    CLOB;
        v_using_clause VARCHAR2(4000);
        v_process_name VARCHAR2(500) := p_process_name;--'ARMEXTN_WorkCertificationApprovalProcess';
    BEGIN
--    DELETE FROM RND;
--     INSERT INTO RND VALUES(
--    p_process_name     ||' p_opa_processid '||
--p_opa_processid       ||' p_approval_status '||
--p_approval_status     ||' p_user '||
--p_user          ||' p_opa_submitted_by '||
--p_opa_submitted_by           ||' p_business_id '||
--p_business_id ||' p_comments '||
--p_comments     ||' p_opa_submitted_date '||
--p_opa_submitted_date     ||' p_last_updated_date '||
-- p_last_updated_date
--
--);
    ----BUILD update script---------
  /*  
    
      FOR i IN (
        SELECT
            table_name,
            process_name,
            output_params,
            opa_id,
            last_update_date,
            last_updated_by,
            last_login_by,
            input_params,
            field_name,
            data_type,
            cursor_sql,
            creation_date,
            created_by,
            column_name,
            attribute9,
            attribute8,
            attribute7,
            attribute6,
            attribute5,
            attribute4,
            attribute3,
            attribute2,
            attribute10,
            attribute1
        FROM
            armopa.xxarm_opa_dny_approval_tab
        WHERE
                process_name = v_process_name
            AND attribute1 IS NULL
            ORDER BY input_params
    ) LOOP
        v_sql_columns := v_sql_columns
                         || ' '
                         || i.column_name
                         || ' = '
                         ||':'|| i.input_params
                         || ' ,';
    END LOOP;
      v_sql_columns:=  RTRIM(v_sql_columns, ' ,');
    FOR k IN (
        SELECT
            column_name,
            input_params
        FROM
            armopa.xxarm_opa_dny_approval_tab
        WHERE
                process_name =v_process_name-- 'ARMEXTN_WorkCertificationApprovalProcess'
            AND attribute1 = 'WHERE'
            
    ) LOOP
        v_where_sql := v_where_sql
                       || k.column_name
                       || ' = '
                       ||'TO_NUMBER(:'|| k.input_params||')';
    END LOOP;
            
        
        
    FOR l_USP IN (SELECT INPUT_PARAMS FROM  armopa.xxarm_opa_dny_approval_tab
        WHERE
                process_name =v_process_name-- 'ARMEXTN_WorkCertificationApprovalProcess'
                AND attribute1 IS NULL
                ORDER BY input_params DESC)
     LOOP
     
     V_USING_CLAUSE:=l_USP.INPUT_PARAMS||' , '||V_USING_CLAUSE;
     
     END LOOP;
  --   V_USING_CLAUSE:=  RTRIM(V_USING_CLAUSE, ' ,');
     V_USING_CLAUSE:=V_USING_CLAUSE||' P_BUSINESS_ID';
     
    FOR j IN (
        SELECT
            distinct table_name
        FROM
            armopa.xxarm_opa_dny_approval_tab
        WHERE
                process_name =v_process_name
            AND attribute1 IS NULL
    ) LOOP
        v_sql := 'UPDATE '
                 || j.table_name
                 || ' SET '
                 || v_sql_columns
                 || ' '
                 || ' WHERE '
                 || v_where_sql;
--                 ||' USING '
--                 || V_USING_CLAUSE||' , P_BUSINESS_ID ';
    END LOOP;

    dbms_output.put_line(v_sql||'  '||V_USING_CLAUSE );
    
    
    
    --x_return_message := 'final sql: '||v_sql;   
    
    --EXECUTE IMMEDIATE v_sql ;--USING V_USING_CLAUSE;
    
    EXECUTE IMMEDIATE v_sql  USING V_USING_CLAUSE;

    --v_sql ;
    DBMS_OUTPUT.PUT_LINE(SQL%ROWCOUNT||' ROWS UPDATED');
    
    */
        IF upper(p_approval_status) = 'SUBMIT' THEN
            UPDATE armopa.xxarm_opa_doc_approval_hier_log_tab
            SET
                opa_instance_id = p_opa_processid
            WHERE
                    busines_id = p_business_id
                AND process_name = p_process_name;

        END IF;

        IF p_process_name = 'ARMEXTN_TechnicalSubmittalsApprovalProcess' THEN
            UPDATE "POSEXT"."XXARM_TECHNICAL_SUBMITTALS_HDR"
            SET
                approval_status = p_approval_status,
                submittals_status =
                    CASE
                        WHEN p_approval_status = 'APPROVE' THEN
                            'Approved'
                        WHEN p_approval_status = 'REJECT'  THEN
                            'Rejected'
                        ELSE
                            submittals_status
                    END,
                last_updated_by = nvl(p_user, - 1),
                last_updated_date = sysdate,
                opa_instance_id = p_opa_processid,
                opa_submit_by =
                    CASE
                        WHEN p_opa_submitted_by IS NOT NULL THEN
                            p_opa_submitted_by
                        ELSE
                            opa_submit_by
                    END,
                opa_submitted_date =
                    CASE
                        WHEN p_opa_submitted_date IS NOT NULL THEN
                            TO_TIMESTAMP_TZ(p_opa_submitted_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
                        ELSE
                            opa_submitted_date
                    END
                
                --comments = p_comments
            WHERE
                ts_id = TO_NUMBER(p_business_id);

        ELSIF p_process_name = 'ARMEXTN_WorkCertificationApprovalProcess' THEN         --OPA_INSTANCE_ID

            UPDATE "POSEXT"."XXARM_WORK_CERTIFICATE_HDR"
            SET
                approval_status = p_approval_status,
                work_cert_status =
                    CASE
                        WHEN p_approval_status = 'APPROVE' THEN
                            'Approved'
                        WHEN p_approval_status = 'REJECT'  THEN
                            'Rejected'
                        ELSE
                            work_cert_status
                    END,
                last_updated_by = p_user,
                last_updated_on = sysdate,
                opa_instance_id =
                    CASE
                        WHEN p_opa_processid IS NOT NULL THEN
                            p_opa_processid
                        ELSE
                            opa_instance_id
                    END,
                opa_submit_by =
                    CASE
                        WHEN p_opa_submitted_by IS NOT NULL THEN
                            p_opa_submitted_by
                        ELSE
                            opa_submit_by
                    END,
                opa_submitted_date =
                    CASE
                        WHEN p_opa_submitted_date IS NOT NULL THEN
                            TO_TIMESTAMP_TZ(p_opa_submitted_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')
                        ELSE
                            opa_submitted_date
                    END,
                comments = p_comments
            WHERE
                wc_certificate_id = TO_NUMBER(p_business_id);

        END IF;

        x_return_message := 'process name '
                            || p_process_name
                            || ' opa id '
                            || p_opa_processid
                            || ' bus id '
                            || p_business_id
                            || ' SUCESS '
                            || SQL%rowcount;

        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_code := 'ERROR';
            x_return_message := x_return_message
                                || ' [APPERR05] Error Others: '
                                || sqlerrm
                                || ' - '
                                || dbms_utility.format_error_backtrace;

      --Log Error into common framework

      --Revert Back Changes
            ROLLBACK;
    -- TODO: Implementation required for PROCEDURE XXARM_CMN_OPA_APPROVAL_PKG.UPDATE_ACTION_APPROVAL_TAB

    END update_action_approval_tab;

  -- +=====================================================================+
  -- | Name        : POST_OPATASK_COMMENTS                                 |
  -- |                                                                     |
  -- | Description : This procedure is used to update approval comments    | 
  -- +=====================================================================+

    PROCEDURE post_opatask_comments (
        p_user               IN VARCHAR2,
        p_opa_instance_id    IN VARCHAR2,
        p_integration_name   IN VARCHAR2,
        p_group_id           IN NUMBER,
        p_busines_id         IN NUMBER,
        p_source_code        IN VARCHAR2,
        p_opa_task_number    IN VARCHAR2,					-- modified datatype by Ayub for OPA
        p_assignee_email     IN VARCHAR2,
        p_assignee_name      IN VARCHAR2,
        p_opa_comment_date   IN VARCHAR2,
        p_process_name       IN VARCHAR2,
        p_attribute1         IN VARCHAR2,
        p_attribute2         IN VARCHAR2,
        p_attribute3         IN VARCHAR2,
        p_attribute4         IN VARCHAR2,
        p_attribute5         IN VARCHAR2,
        p_attribute6         IN VARCHAR2,
        p_attribute7         IN VARCHAR2,
        p_attribute8         IN VARCHAR2,
        p_attribute9         IN VARCHAR2,
        p_attribute10        IN VARCHAR2,
        p_last_update_date   IN VARCHAR2,					-- modified datatype by Ayub for OPA	
        p_created_by         IN VARCHAR2,
        p_last_updated_by    IN VARCHAR2,
        p_last_login_by      IN VARCHAR2,
        p_task_user_comments IN VARCHAR2,
        p_task_comment_id    IN VARCHAR2,					-- Added by Venkat
        x_return_message     OUT VARCHAR2,
        x_return_code        OUT VARCHAR2
    ) AS
    --Local Variables
        l_return_code     VARCHAR2(240);
        l_return_message  VARCHAR2(4000);
        l_task_comment_id armopa.xxarm_opa_task_comments_tab.task_comment_id%TYPE;
        l_employee_name   armopa.xxarm_opa_task_comments_tab.assignee_name%TYPE;
        l_exists_count    NUMBER DEFAULT 0;
    BEGIN
    --Initialze
        x_return_code := 'SUCCESS';
        x_return_message := 'SUCCESS';
        BEGIN
    -- TODO: Implementation required for PROCEDURE XXARM_CMN_OPA_APPROVAL_PKG.POST_OPATASK_COMMENTS
            SELECT
                COUNT(1)
            INTO l_exists_count
            FROM
                armopa.xxarm_opa_task_comments_tab
            WHERE
                    opa_instance_id = p_opa_instance_id
                AND lower(task_user_comments) = lower(p_task_user_comments);
                --AND assignee_email = p_assignee_email
                --AND opa_task_number = p_opa_task_number;

            IF ( l_exists_count = 0 ) THEN
      --Create Record into Stage
                INSERT INTO armopa.xxarm_opa_task_comments_tab (
                    busines_id,
                    source_code,
                    opa_instance_id,
                    opa_task_number,
                    assignee_email,
                    assignee_name,
                    opa_comment_date,
                    process_name,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    last_update_date,
                    created_by,
                    last_updated_by,
                    task_user_comments,
                    task_comment_id
                ) VALUES (
                    p_busines_id,
                    p_source_code,
                    p_opa_instance_id,
                    p_opa_task_number,
                    p_assignee_email,
                    nvl(p_assignee_name, l_employee_name),
                    CAST(TO_TIMESTAMP_TZ(p_opa_comment_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE),
                    p_process_name,
                    p_attribute1,
                    p_attribute2,
                    p_attribute3,
                    p_attribute4,
                    p_attribute5,
                    p_attribute6,
                    p_attribute7,
                    p_attribute8,
                    p_attribute9,
                    p_attribute10,
                    TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
                    p_created_by,
                    p_last_updated_by,
                    p_task_user_comments,
                    p_task_comment_id
                );

            END IF;

            x_return_message := 'SUCCESS. Count: ' || SQL%rowcount;
        END;

    END post_opatask_comments;

  -- +=====================================================================+
  -- | Name        : POST_OPAUSER_TASKINFO                                 |
  -- |                                                                     |
  -- | Description : This procedure is to insert user task approval history| 
  -- +=====================================================================+

    PROCEDURE post_opauser_taskinfo (
        p_business_id          IN VARCHAR2,
        p_source_code          IN VARCHAR2,
        p_opa_process_id       IN VARCHAR2,
        p_opa_task_number      IN VARCHAR2,
        p_opa_task_status      IN VARCHAR2,
        p_opa_task_substate    IN VARCHAR2,
        p_assignee_email       IN VARCHAR2,
        p_assignee_name        IN VARCHAR2,
        p_fromuser_email       IN VARCHAR2,
        p_fromuser_name        IN VARCHAR2,
        p_opa_action           IN VARCHAR2,
        p_opa_action_date      IN VARCHAR2,
        p_opa_task_title       IN VARCHAR2,
        p_task_user_comments   IN VARCHAR2,
        p_previous_task_number IN VARCHAR2,
        p_approval_roles       IN VARCHAR2,
        p_task_summary         IN VARCHAR2,
        p_task_definitionkey   IN VARCHAR2,
        p_attribute1           IN VARCHAR2,
        p_attribute2           IN VARCHAR2,
        p_attribute3           IN VARCHAR2,
        p_attribute4           IN VARCHAR2,
        p_attribute5           IN VARCHAR2,
        p_attribute6           IN VARCHAR2,
        p_attribute7           IN VARCHAR2,
        p_attribute8           IN VARCHAR2,
        p_attribute9           IN VARCHAR2,
        p_attribute10          IN VARCHAR2,
        p_process_name         IN VARCHAR2,
        p_creation_date        IN VARCHAR2,
        p_last_update_date     IN VARCHAR2,
        p_created_by           IN VARCHAR2,
        p_createdby_email      IN VARCHAR2,
        p_last_updated_by      IN VARCHAR2,
        p_last_login_by        IN VARCHAR2,
        p_instance_id          IN VARCHAR2,
        p_integration_name     IN VARCHAR2,
        p_user                 IN VARCHAR2,
        x_return_message       OUT VARCHAR2,
        x_return_code          OUT VARCHAR2
    ) AS
        l_exists_count  NUMBER;
        l_submit_count  NUMBER;
        lv_opa_action   VARCHAR2(250);
        lv_final_action VARCHAR2(250);
        lv_taskseq_id   NUMBER;
    BEGIN
        IF (
            p_opa_task_substate LIKE 'REASSIGNED'
            AND p_opa_task_status = 'COMPLETED'
            AND ( p_opa_action IN ('REJECT','APPROVE') )
        ) THEN
            lv_final_action := p_opa_action;
        ELSIF
            p_opa_task_substate LIKE 'REASSIGNED'
            AND p_opa_task_status <> 'COMPLETED'
            AND ( p_opa_action NOT IN ( 'APPROVE', 'REJECT' ) )
        THEN
            lv_final_action := p_opa_task_substate;
        ELSIF p_opa_task_substate LIKE 'INFO_REQUESTED' THEN
            lv_final_action := 'Requested For More Info.';
        ELSIF p_opa_task_substate LIKE 'WITHDRAWN' THEN
            lv_final_action := p_opa_task_substate;
        ELSIF p_opa_task_status LIKE 'ASSIGN%' THEN
            lv_final_action := p_opa_task_status;
        ELSIF
            p_opa_task_status LIKE 'COMPLETE%'
            AND ( p_opa_action NOT IN ( 'APPROVE', 'REJECT' ) )
            AND p_opa_task_substate NOT LIKE 'REASSIGNED'
        THEN
            lv_final_action := p_opa_action;
ELSIF
            p_opa_task_status LIKE 'COMPLETE%'
            AND ( p_opa_action  IN ( 'APPROVE', 'REJECT' ) )
            AND p_opa_task_substate NOT LIKE 'REASSIGNED'
        THEN
            lv_final_action := p_opa_action;
        ELSIF
            p_opa_task_status = 'INITIATED%'
            AND p_opa_task_status = 'ASSIGNED'
        THEN
            lv_final_action := 'ASSIGNED';
        ELSIF
            p_opa_action = 'INITIATED'
            AND p_opa_task_status = 'ASSIGNED'
        THEN
            lv_final_action := 'ASSIGNED';
        ELSIF
            p_opa_task_title = 'WITHDRAWN'
            AND p_opa_task_status = 'ACTIVE'
        THEN
            lv_final_action := p_opa_task_title;
        ELSE
            lv_final_action := nvl(p_opa_task_substate, p_opa_task_status);
        END IF;

        SELECT
            COUNT(1)
        INTO l_submit_count
        FROM
            armopa.xxarm_opa_user_tasks_tab
        WHERE
                opa_instance_id = p_opa_process_id
       --AND OPA_TASK_NUMBER           = p_opa_task_number
            AND opa_task_status = 'SUBMIT'
            AND ROWNUM = 1;

        IF lv_final_action = 'WITHDRAWN' OR lv_final_action = 'REJECT'  THEN
            DELETE FROM armopa.xxarm_opa_user_tasks_tab
            WHERE
                    opa_instance_id = p_opa_process_id
                AND opa_action = 'ASSIGNED';

        END IF;

        IF l_submit_count = 0 THEN--l_exists_count
    -- TODO: Implementation required for PROCEDURE XXARM_CMN_OPA_APPROVAL_PKG.POST_OPAUSER_TASKINFO
            INSERT INTO armopa.xxarm_opa_user_tasks_tab (
                business_id,
                source_code,
                opa_instance_id,
                opa_task_number,
                opa_task_status,
                opa_task_substate,
                assignee_email,
                assignee_name,
                fromuser_email,
                fromuser_name,
                opa_action,
                opa_action_date,
                opa_task_title,
                task_user_comments,
                previous_task_number,
                approval_roles,
                task_summary,
                task_definitionkey,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                process_name,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by,
                last_login_by
            ) VALUES (
                p_business_id                --business_id
                ,
                p_source_code                --,source_code
                ,
                p_opa_process_id             --,pcs_process_id
                ,
                p_instance_id            --,pcs_task_number
                ,
                'SUBMIT'            --,pcs_task_status
                ,
                'SUBMIT'          --,pcs_task_substate
                ,
                p_createdby_email             --,assignee_email
                ,
                nvl(p_created_by, p_createdby_email)              --,assignee_name
                ,
                p_fromuser_email             --,fromuser_email
                ,
                nvl(p_fromuser_name, p_fromuser_email)              --,fromuser_name
                ,
                'SUBMIT'                              --,pcs_action
                ,
                CAST(TO_TIMESTAMP_TZ(p_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE)    --,pcs_action_date
                ,
                p_opa_task_title             --,pcs_task_title
                ,
                p_task_user_comments         --,task_user_comments
                ,
                p_previous_task_number       --,previous_task_number
                ,
                p_approval_roles             --,approval_roles
                ,
                p_task_summary               --,task_summary
                ,
                p_task_definitionkey         --,task_definitionkey
                ,
                p_attribute1 || ' 0'                 --,attribute1
                ,
                p_attribute2                 --,attribute2
                ,
                p_attribute3                 --,attribute3
                ,
                p_attribute4                 --,attribute4
                ,
                p_attribute5                 --,attribute5
                ,
                p_attribute6                 --,attribute6
                ,
                p_attribute7                 --,attribute7
                ,
                p_attribute8                 --,attribute8
                ,
                p_attribute9                 --,attribute9
                ,
                p_attribute10                --,attribute10
                ,
                p_process_name               --,process_name
                ,
                TO_TIMESTAMP_TZ(p_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')               --,creation_date
                ,
                TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')            --,last_update_date
                ,
                p_created_by                 --,created_by
                ,
                nvl(p_last_updated_by, '-1')            --,last_updated_by
                ,
                p_last_login_by
            );            --,last_login_by
        END IF; --IF l_exists_count > 0


        SELECT
            COUNT(1)
        INTO l_exists_count
        FROM
            armopa.xxarm_opa_user_tasks_tab
        WHERE
                opa_instance_id = p_opa_process_id
            AND opa_task_number = p_opa_task_number
            --AND opa_action=lv_final_action
            ;

        IF
            l_exists_count = 0
            AND ( lv_final_action IN ( 'APPROVE', 'REJECT', 'ASSIGNED', 'TERMINATE', 'WITHDRAWN' ) )---p_opa_action IN ( 'APPROVE', 'REJECT', 'ASSIGNED', 'TERMINATE', 'WITHDRAWN' ) OR 
        THEN
            x_return_message := '11';
    -- TODO: Implementation required for PROCEDURE XXARM_CMN_OPA_APPROVAL_PKG.POST_OPAUSER_TASKINFO
            INSERT INTO armopa.xxarm_opa_user_tasks_tab (
                business_id,
                source_code,
                opa_instance_id,
                opa_task_number,
                opa_task_status,
                opa_task_substate,
                assignee_email,
                assignee_name,
                fromuser_email,
                fromuser_name,
                opa_action,
                opa_action_date,
                opa_task_title,
                task_user_comments,
                previous_task_number,
                approval_roles,
                task_summary,
                task_definitionkey,
                attribute1,
                attribute2,
                attribute3,
                attribute4,
                attribute5,
                attribute6,
                attribute7,
                attribute8,
                attribute9,
                attribute10,
                process_name,
                creation_date,
                last_update_date,
                created_by,
                last_updated_by,
                last_login_by
            ) VALUES (
                p_business_id                --business_id
                ,
                p_source_code                --,source_code
                ,
                p_opa_process_id             --,pcs_process_id
                ,
                p_opa_task_number            --,pcs_task_number
                ,
                    CASE
                        WHEN upper(lv_final_action) LIKE 'WITHDRAW%' THEN
                            lv_final_action
                        ELSE
                            p_opa_task_status
                    END             --,pcs_task_status
                    ,
                p_opa_task_substate          --,pcs_task_substate
                ,
                p_assignee_email             --,assignee_email
                ,
                p_assignee_name              --,assignee_name
                ,
                p_fromuser_email             --,fromuser_email
                ,
                p_fromuser_name              --,fromuser_name
                ,
                lv_final_action--DECODE(p_opa_action, 'INITIATED', 'ASSIGNED', p_opa_action)                              --,pcs_action
                ,
                CAST(TO_TIMESTAMP_TZ(p_opa_action_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE)    --,pcs_action_date
                ,
                p_opa_task_title             --,pcs_task_title
                ,
                p_task_user_comments         --,task_user_comments
                ,
                p_previous_task_number       --,previous_task_number
                ,
                p_approval_roles             --,approval_roles
                ,
                p_task_summary               --,task_summary
                ,
                p_task_definitionkey         --,task_definitionkey
                ,
                p_attribute1 || ' 1'                 --,attribute1
                ,
                p_attribute2                 --,attribute2
                ,
                p_attribute3                 --,attribute3
                ,
                p_attribute4                 --,attribute4
                ,
                p_attribute5                 --,attribute5
                ,
                p_attribute6                 --,attribute6
                ,
                p_attribute7                 --,attribute7
                ,
                p_attribute8                 --,attribute8
                ,
                p_attribute9                 --,attribute9
                ,
                p_attribute10                --,attribute10
                ,
                p_process_name               --,process_name
                ,
                TO_TIMESTAMP_TZ(p_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')               --,creation_date
                ,
                TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')            --,last_update_date
                ,
                p_created_by                 --,created_by
                ,
                nvl(p_last_updated_by, '-1')            --,last_updated_by
                ,
                p_last_login_by
            );            --,last_login_by
        ELSIF
            l_exists_count > 0
            AND ( lv_final_action NOT IN ( 'APPROVE', 'REJECT', 'SUBMIT', 'ASSIGNED' ) )   --p_opa_action NOT IN ( 'APPROVE', 'REJECT', 'SUBMIT') OR
        THEN
            l_exists_count := 0;
            SELECT
                COUNT(1)
            INTO l_exists_count
            FROM
                armopa.xxarm_opa_user_tasks_tab
            WHERE
                    opa_instance_id = p_opa_process_id
                AND opa_task_number = p_opa_task_number
                AND opa_action = lv_final_action
                AND lower(assignee_email) = lower(p_assignee_email)    ;

            IF l_exists_count = 0 THEN
                INSERT INTO armopa.xxarm_opa_user_tasks_tab (
                    business_id,
                    source_code,
                    opa_instance_id,
                    opa_task_number,
                    opa_task_status,
                    opa_task_substate,
                    assignee_email,
                    assignee_name,
                    fromuser_email,
                    fromuser_name,
                    opa_action,
                    opa_action_date,
                    opa_task_title,
                    task_user_comments,
                    previous_task_number,
                    approval_roles,
                    task_summary,
                    task_definitionkey,
                    attribute1,
                    attribute2,
                    attribute3,
                    attribute4,
                    attribute5,
                    attribute6,
                    attribute7,
                    attribute8,
                    attribute9,
                    attribute10,
                    process_name,
                    creation_date,
                    last_update_date,
                    created_by,
                    last_updated_by,
                    last_login_by
                ) VALUES (
                    p_business_id                --business_id
                    ,
                    p_source_code                --,source_code
                    ,
                    p_opa_process_id             --,pcs_process_id
                    ,
                    p_opa_task_number            --,pcs_task_number
                    ,
                    p_opa_task_status            --,pcs_task_status
                    ,
                    p_opa_task_substate          --,pcs_task_substate
                    ,
                    p_assignee_email             --,assignee_email
                    ,
                    nvl(p_assignee_name, p_assignee_email)              --,assignee_name
                    ,
                    p_fromuser_email             --,fromuser_email
                    ,
                    p_fromuser_name              --,fromuser_name
                    ,
                    lv_final_action--DECODE(p_opa_action, 'INITIATED', 'ASSIGNED', p_opa_action)                              --,pcs_action
                    ,
                    CAST(TO_TIMESTAMP_TZ(p_opa_action_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE)    --,pcs_action_date
                    ,
                    p_opa_task_title             --,pcs_task_title
                    ,
                    p_task_user_comments         --,task_user_comments
                    ,
                    p_previous_task_number       --,previous_task_number
                    ,
                    p_approval_roles             --,approval_roles
                    ,
                    p_task_summary               --,task_summary
                    ,
                    p_task_definitionkey         --,task_definitionkey
                    ,
                    p_attribute1 || ' 2'                  --,attribute1
                    ,
                    p_attribute2                 --,attribute2
                    ,
                    p_attribute3                 --,attribute3
                    ,
                    p_attribute4                 --,attribute4
                    ,
                    p_attribute5                 --,attribute5
                    ,
                    p_attribute6                 --,attribute6
                    ,
                    p_attribute7                 --,attribute7
                    ,
                    p_attribute8                 --,attribute8
                    ,
                    p_attribute9                 --,attribute9
                    ,
                    p_attribute10                --,attribute10
                    ,
                    p_process_name               --,process_name
                    ,
                    TO_TIMESTAMP_TZ(p_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')               --,creation_date
                    ,
                    TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')            --,last_update_date
                    ,
                    p_created_by                 --,created_by
                    ,
                    nvl(p_last_updated_by, '-1')            --,last_updated_by
                    ,
                    p_last_login_by
                );            --,last_login_by
            END IF;

        ELSIF
            l_exists_count > 0
            AND ( lv_final_action IN ( 'APPROVE', 'REJECT' ) )--- p_opa_action IN ( 'APPROVE', 'REJECT' ) OR 
        THEN
            x_return_message := '12';
            SELECT
                action,taskseq_id
            INTO lv_opa_action,lv_taskseq_id 
            FROM
                (
                    SELECT
                        nvl(opa_action, opa_task_substate) action,taskseq_id
                    FROM
                        armopa.xxarm_opa_user_tasks_tab
                    WHERE
                            opa_instance_id = p_opa_process_id
                        AND opa_task_number = p_opa_task_number
                    ORDER BY
                        taskseq_id DESC
                )
            WHERE
                ROWNUM = 1;

--            SELECT
--                nvl(opa_action, opa_task_substate)
--            INTO lv_opa_action
--            FROM
--                armopa.xxarm_opa_user_tasks_tab
--            WHERE
--                    opa_instance_id = p_opa_process_id
--                AND opa_task_number = p_opa_task_number
--                AND ROWNUM = 1;
--
            IF
                upper(lv_opa_action) LIKE '%ASSIGN%'
                AND lv_final_action IN ( 'APPROVE', 'REJECT' )
            THEN
                x_return_message := x_return_message
                                    || ' '
                                    || '13';
                UPDATE armopa.xxarm_opa_user_tasks_tab
                SET
                    opa_action = lv_final_action,--p_opa_action,
                    last_update_date = TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM'),
                    last_updated_by = p_last_updated_by,
                    opa_action_date = CAST(TO_TIMESTAMP_TZ(p_opa_action_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE),
                    opa_task_status =
                        CASE
                            WHEN upper(lv_final_action) LIKE 'WITHDRAW%' THEN
                                lv_final_action
                            ELSE
                                p_opa_task_status
                        END,
                    opa_task_substate = p_opa_task_substate,          --,pcs_task_substate
                    assignee_email = p_assignee_email,
                    assignee_name = p_assignee_name,
                    fromuser_email = p_fromuser_email,             --,fromuser_email
                    fromuser_name = p_fromuser_name  ,            --,fromuser_name
                    attribute2  = 'update ' ||lv_final_action
                WHERE
                        opa_instance_id = p_opa_process_id
                    AND opa_task_number = p_opa_task_number
                    AND upper(opa_action) like upper(lv_opa_action)
                    AND taskseq_id  =   lv_taskseq_id;

            ELSE
                IF (
                    p_opa_action <> 'SUBMIT'
                    AND lv_opa_action <> 'REJECT'
                    AND lv_opa_action <> 'APPROVE'
                ) THEN
                    INSERT INTO armopa.xxarm_opa_user_tasks_tab (
                        business_id,
                        source_code,
                        opa_instance_id,
                        opa_task_number,
                        opa_task_status,
                        opa_task_substate,
                        assignee_email,
                        assignee_name,
                        fromuser_email,
                        fromuser_name,
                        opa_action,
                        opa_action_date,
                        opa_task_title,
                        task_user_comments,
                        previous_task_number,
                        approval_roles,
                        task_summary,
                        task_definitionkey,
                        attribute1,
                        attribute2,
                        attribute3,
                        attribute4,
                        attribute5,
                        attribute6,
                        attribute7,
                        attribute8,
                        attribute9,
                        attribute10,
                        process_name,
                        creation_date,
                        last_update_date,
                        created_by,
                        last_updated_by,
                        last_login_by
                    ) VALUES (
                        p_business_id                --business_id
                        ,
                        p_source_code                --,source_code
                        ,
                        p_opa_process_id             --,pcs_process_id
                        ,
                        p_opa_task_number            --,pcs_task_number
                        ,
                        p_opa_task_status            --,pcs_task_status
                        ,
                        p_opa_task_substate          --,pcs_task_substate
                        ,
                        p_assignee_email             --,assignee_email
                        ,
                        p_assignee_name              --,assignee_name
                        ,
                        p_fromuser_email             --,fromuser_email
                        ,
                        p_fromuser_name              --,fromuser_name
                        ,
                        lv_final_action--DECODE(p_opa_action, 'INITIATED', 'ASSIGNED', p_opa_action)                              --,pcs_action
                        ,
                        CAST(TO_TIMESTAMP_TZ(p_opa_action_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM') AS DATE)    --,pcs_action_date
                        ,
                        p_opa_task_title             --,pcs_task_title
                        ,
                        p_task_user_comments         --,task_user_comments
                        ,
                        p_previous_task_number       --,previous_task_number
                        ,
                        p_approval_roles             --,approval_roles
                        ,
                        p_task_summary               --,task_summary
                        ,
                        p_task_definitionkey         --,task_definitionkey
                        ,
                        p_attribute1 || '3'                 --,attribute1
                        ,
                        p_attribute2                 --,attribute2
                        ,
                        p_attribute3                 --,attribute3
                        ,
                        p_attribute4                 --,attribute4
                        ,
                        p_attribute5                 --,attribute5
                        ,
                        p_attribute6                 --,attribute6
                        ,
                        p_attribute7                 --,attribute7
                        ,
                        p_attribute8                 --,attribute8
                        ,
                        p_attribute9                 --,attribute9
                        ,
                        p_attribute10                --,attribute10
                        ,
                        p_process_name               --,process_name
                        ,
                        TO_TIMESTAMP_TZ(p_creation_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')               --,creation_date
                        ,
                        TO_TIMESTAMP_TZ(p_last_update_date, 'YYYY-MM-DD"T"HH24:MI:SS.FF3TZH:TZM')            --,last_update_date
                        ,
                        p_created_by                 --,created_by
                        ,
                        nvl(p_last_updated_by, '-1')            --,last_updated_by
                        ,
                        p_last_login_by
                    );            --,last_login_by
                END IF;
            END IF;

        END IF;

        x_return_message := x_return_message
                            || ' '
                            || 'SUCCESS. Count: '
                            || SQL%rowcount
                            || ' '
                            || p_assignee_name
                            || ' '
                            || lv_opa_action;

    --Save CHanges
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            x_return_code := 'MAIN EXCEPTION ERROR';
            x_return_message := '[APPERR05] Error Others: '
                                || sqlerrm
                                || ' - '
                                || dbms_utility.format_error_backtrace;
    END post_opauser_taskinfo;


  -- +=====================================================================+
  -- | Name        : GET_APPROVAL_DATA                                      |
  -- |                                                                      |
  -- | Description : This procedure is to show approval data on OPA flow    | 
  -- +=====================================================================+
    PROCEDURE get_approval_data (
        p_opa_processid    IN VARCHAR2,
        p_approval_status  IN VARCHAR2,
        p_user             IN VARCHAR2,
        p_userid           IN VARCHAR2,
        p_process_name     IN VARCHAR2,
        p_bussiness_id     IN VARCHAR2,
        p_doctype          IN VARCHAR2,
        p_business_unit_id IN VARCHAR2,
        p_amount           IN VARCHAR2,
        p_retryflag        IN VARCHAR2,
        p_adhoclevel       IN VARCHAR2,
        p_currentlevel     IN NUMBER,
        x_data             OUT SYS_REFCURSOR,
        x_approverinfo     OUT SYS_REFCURSOR,
        x_currentlevel     OUT NUMBER,
        x_maxlevel         OUT NUMBER,
        x_return_code      OUT VARCHAR2,
        x_return_message   OUT VARCHAR2
    ) AS

        ln_levelcount     NUMBER DEFAULT 0;
        lv_mgr_name       VARCHAR2(300);
        lv_mgr_emp_number VARCHAR2(50);
        lv_mgr_email      VARCHAR2(300);
        lv_mgr_username   armhcm.per_users.username%TYPE;
        lv_mgr_personid   VARCHAR2(300);
    BEGIN
        ln_levelcount := p_currentlevel;
        IF p_approval_status = 'APPROVE' THEN
            ln_levelcount := ln_levelcount + 1;
        ELSIF p_retryflag = 'Y' THEN
            ln_levelcount := p_adhoclevel;
        END IF;

        IF ( p_amount IS NULL OR p_amount = 0 ) THEN
            x_return_message := 'Input Amount cannot be null';
        END IF;

        IF ( p_bussiness_id IS NULL OR p_amount = 0 ) THEN
            x_return_message := 'Input Business Id cannot be null';
        END IF;

        IF p_process_name IS NULL THEN
            x_return_message := 'Input Process Name cannot be null';
        END IF;
        IF p_business_unit_id IS NULL THEN
            x_return_message := 'Input Business Unit Id cannot be null';
        END IF;
        IF p_currentlevel IS NULL THEN
            x_return_message := 'Input Current Level cannot be null';
        END IF;
        x_currentlevel := ln_levelcount;
--        SELECT
--            count(1)
--        INTO x_maxlevel
--        FROM
--            (
--                SELECT
--                    alht.business_unit_id,
--                    alht.business_unit_name,
--                    alht.document_type,
--                    alht.document_type_id,
--                    alht.approval_limit_from,
--                    alht.approval_limit_to,
--                    alht.approvers_id,
--                    approver_id,
--                    NULL                          approver_name
--                FROM
--                    posext.xxarm_apprv_limits_hierarchy_tab UNPIVOT ( approver_id
--                        FOR approvers_id
--                    IN ( approver1_id,
--                         approver2_id,
--                         approver3_id,
--                         approver4_id,
--                         approver5_id,
--                         approver6_id,
--                         approver7_id,
--                         approver8_id,
--                         approver9_id,
--                         approver10_id ) ) alht
--                WHERE
--                        alht.document_type_id = p_doctype
--                    AND p_amount BETWEEN alht.approval_limit_from AND NVL(alht.approval_limit_to,9999999)
--                    AND business_unit_id = NVL(p_business_unit_id,300000008187644)
--            ) apprv;

        SELECT
            COUNT(1)
        INTO x_maxlevel
        FROM
            armopa.xxarm_opa_doc_approval_hier_log_tab
        WHERE
                process_name = p_process_name
            AND document_typeid = p_doctype
            AND busines_id = p_bussiness_id;

        xxarm_get_opa_approvers_utility_pkg.get_approvers_list(p_process_name => p_process_name, p_emp_number => p_user, p_emp_personid => p_userid
        , p_doctype => p_doctype, p_amount => p_amount,
                                                              p_business_unit_id => p_business_unit_id, p_currentlevel => x_currentlevel
                                                              , p_business_id => p_bussiness_id, x_mgr_name => lv_mgr_name, x_mgr_emp_number => lv_mgr_emp_number
                                                              ,
                                                              x_mgr_email => lv_mgr_email, x_mgr_username => lv_mgr_username, x_mgr_personid => lv_mgr_personid
                                                              , x_return_code => x_return_code, x_return_message => x_return_message)
                                                              ;

        OPEN x_approverinfo FOR SELECT
                                   NULL                               business_unit_id,
                                   NULL                               business_unit_name,
                                   NULL                               document_type,
                                   NULL                               document_type_id,
                                   NULL                               approval_limit_from,
                                   NULL                               approval_limit_to,
                                   lv_mgr_emp_number                  approvers_id,
                                   nvl(lv_mgr_username, lv_mgr_email) approver_id,
                                   lv_mgr_name                        approver_name,
                                   lv_mgr_personid                    approver_personid
                               FROM
                                   dual;

        IF p_process_name = 'ARMEXTN_TechnicalSubmittalsApprovalProcess' THEN
            OPEN x_data FOR SELECT
                                                tsh.ts_id,
                                                pha.po_header_id,
                                                tsh.submittals_no,
                                                tsh.submittals_status,
                                                decode(tsh.comments, NULL, '', tsh.comments) comments,
                                                tsh.created_by,
                                                tsh.creation_date,
                                                tsh.last_updated_by,
                                                tsh.last_updated_date,
                                                tsh.approval_status,
                                                tsh.opa_instance_id,
                                                tsh.opa_submitted_date,
                                                tsh.opa_submit_by,
                                                pha.segment1                                 purchase_order_number,
                                                'XXARM_TECHNICAL_SUBMITTALS_HDR'             tab_name,
                                                (
                                                    SELECT
                                                        houftl.name
                                                    FROM
                                                        armhcm.hr_organization_units_f_tl houftl
                                        --armscm.po_headers_all             pha
                                                    WHERE
                                                            houftl.organization_id = pha.billto_bu_id
                                                        AND ROWNUM = 1
                                                )                                            sold_to_business_unit,
                                                (
                                                    SELECT
                                                        ppf.first_name
                                                        || ' '
                                                        || ppf.middle_names
                                                        || ' '
                                                        || ppf.last_name buyer_name
                                                    FROM
                                                        armhcm.per_person_names_f ppf
                                                    WHERE
                                                            ppf.person_id = pha.agent_id
                                                        AND trunc(sysdate) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
                                                        AND ppf.name_type = 'GLOBAL'
                                                        AND ppf.char_set_context = 'US'
                                                        AND ROWNUM = 1
                                                )                                            requestor,
                                                (
                                                    SELECT
                                                        party_name
                                                    FROM
                                                        armscm.poz_suppliers_all sup,
                                                        armerp.hz_parties        hp
                                                    WHERE
                                                            hp.party_id = sup.party_id
                                                        AND sup.vendor_id = pha.vendor_id
                                                )                                            supplier,
                                                CURSOR (
                                                    SELECT
                                                        tsl.*,
                                                        CURSOR (
                                                            SELECT
                                                                doc_seq_key,
                                                                doc_id,
                                                                document_category,
                                                                document_name,
                                                                mimetype,
                                                                document_link,
                                                                object_name,
                                                                object_id,
                                                                bu_name,
                                                                submitted_doc_type,
                                                                po_header_id,
                                                                tsl.submittals business_identifier,
                                                                creation_date,
                                                                created_by,
                                                                last_update_date,
                                                                last_updated_by
                                                            FROM
                                                                posext.xxarm_po_documents_tab
                                                            WHERE
                                                                    object_name = 'XXARM_TECHNICAL_SUBMITTALS_LINES'
                                                                AND object_id = tsl.ts_line_id
                                                        ) AS line_attachements
                                                    FROM
                                                        posext.xxarm_technical_submittals_lines tsl
                                                    WHERE
                                                        ts_id = tsh.ts_id
                                                )                                            lines_data,
                                                CURSOR (
                                                    SELECT
                                                        doc_seq_key,
                                                        doc_id,
                                                        document_category,
                                                        document_name,
                                                        mimetype,
                                                        document_link,
                                                        object_name,
                                                        object_id,
                                                        bu_name,
                                                        submitted_doc_type,
                                                        po_header_id,
                                                        business_identifier,
                                                        creation_date,
                                                        created_by,
                                                        last_update_date,
                                                        last_updated_by
                                                    FROM
                                                        posext.xxarm_po_documents_tab
                                                    WHERE
                                                            object_name = 'XXARM_TECHNICAL_SUBMITTALS_HDR'
                                                        AND object_id = tsh.ts_id
                                                )                                            AS ts_hdr_attachments
                                            FROM
                                                posext.xxarm_technical_submittals_hdr tsh,
                                                armscm.po_headers_all                 pha
                            WHERE
                                    ts_id = TO_NUMBER(p_bussiness_id)
                                AND pha.po_header_id = tsh.po_header_id
                                AND ROWNUM = 1;

        ELSIF p_process_name = 'ARMEXTN_WorkCertificationApprovalProcess' THEN
            OPEN x_data FOR SELECT
                                                wch.wc_certificate_id,
                                                wch.po_header_id,
                                                wch.checklist_id,
                                                decode(wch.comments, NULL, '', wch.comments)                                 comments
                                                ,
                                                wch.work_cert_no,
                                                wch.work_cert_status,
                                                to_char(wch.work_cert_date, 'DD-Mon-YYYY')                                   work_cert_date
                                                ,
                                                to_char(wch.period_start_date, 'DD-Mon-YYYY')                                period_start_date
                                                ,
                                                to_char(wch.period_end_date, 'DD-Mon-YYYY')                                  period_end_date
                                                ,
                                                to_char(wch.po_creation_date, 'DD-MM-YYYY')                                  po_creation_date
                                                ,
                                                decode(to_char(nvl(wch.cert_total_amount, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.cert_total_amount, 'FM999,999,999,999,999.00'))           cert_total_amount
                                                       ,
                                                decode(to_char(nvl(wch.retainage_deduction, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.retainage_deduction, 'FM999,999,999,999,999.00'))         retainage_deduction
                                                       ,
                                                decode(to_char(nvl(wch.adv_payment_deduction, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.adv_payment_deduction, 'FM999,999,999,999,999.00'))       adv_payment_deduction
                                                       ,
                                                decode(to_char(nvl(wch.other_deductions, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.other_deductions, 'FM999,999,999,999,999.00'))            other_deductions
                                                       ,
                                                decode(to_char(nvl(wch.cert_net_amount, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.cert_net_amount, 'FM999,999,999,999,999.00'))             cert_net_amount
                                                       ,
                                                decode(to_char(nvl(wch.contract_amount, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.contract_amount, 'FM999,999,999,999,999.00'))             contract_amount
                                                       ,
                                                decode(to_char(nvl(wch.previously_approved, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.previously_approved, 'FM999,999,999,999,999.00'))         previously_approved
                                                       ,
                                                decode(to_char(nvl(wch.total_completed_this_period, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.total_completed_this_period, 'FM999,999,999,999,999.00')) total_completed_this_period
                                                       ,
                                                decode(to_char(nvl(wch.total_completed_to_date, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.total_completed_to_date, 'FM999,999,999,999,999.00'))     total_completed_to_date
                                                       ,
                                                decode(to_char(nvl(wch.retainage_to_date, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.retainage_to_date, 'FM999,999,999,999,999.00'))           retainage_to_date
                                                       ,
                                                decode(to_char(nvl(wch.balance_to_finish, 0),
                                                               'FM999,999,999,999,999.00'),
                                                       '.00',
                                                       '0.00',
                                                       to_char(wch.balance_to_finish, 'FM999,999,999,999,999.00'))           balance_to_finish
                                                       ,
                                                wch.submitted_by,
                                                wch.created_by,
                                                wch.created_on,
                                                wch.last_updated_by,
                                                wch.last_updated_on,
                                                wch.billto_bu_id,
                                                wch.vendor_id,
                                                wch.po_number,
                                                nvl(wch.po_descripition, '')                                                 po_descripition
                                                ,
                                                wch.procurement_bu,
                                                wch.po_line_id,
                                                requester_id,
                                                wch.requester_name,
                                                wch.preparer_id,
                                                wch.preparer_name,
                                                wch.requisition_number,
                                                wch.supplier_name,
                                                wch.supplier_address1,
                                                wch.supplier_address2,
                                                wch.supplier_city,
                                                wch.supplier_contact,
                                                wch.supplier_email,
                                                wch.supplier_mobile,
                                                wch.po_currency,
                                                wch.agent_id,
                                                wch.buyer_name,
                                                wch.buyer_address,
                                                wch.le_name,
                                                wch.opa_instance_id,
                                                wch.receipt_number,
                                                wch.advance_invoice_number,
                                                wch.interface_error,
                                                'XXARM_WORK_CERTIFICATE_HDR'                                                 tab_name
                                                ,
                                                CURSOR (
                                                    SELECT
                                                        wcl.wc_certificate_line_id,
                                                        wcl.po_line_id,
                                                        decode(to_char(nvl(wcl.quantity_completed, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.quantity_completed, 'FM999,999,999,999,999.00'))                                             quantity_completed
                                                               ,
                                                        decode(to_char(nvl(wcl.amount_completed, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.amount_completed, 'FM999,999,999,999,999.00'))                                               amount_completed
                                                               ,
                                                        decode(to_char(nvl(wcl.progress_percentage, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(progress_percentage))                                                                            progress_percentage
                                                               ,
                                                        decode(to_char(nvl(wcl.projected_retainage, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.projected_retainage, 'FM999,999,999,999,999.00'))                                            projected_retainage
                                                               ,
                                                        decode(to_char(nvl(wcl.total_completed_to_date, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.total_completed_to_date, 'FM999,999,999,999,999.00'))                                        total_completed_to_date
                                                               ,
                                                        decode(to_char(nvl(wcl.projected_retainage_to_date, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.projected_retainage_to_date, 'FM999,999,999,999,999.00'))                                    projected_retainage_to_date
                                                               ,
                                                        decode(to_char(nvl(wcl.balance_to_finish, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(wcl.balance_to_finish, 'FM999,999,999,999,999.00'))                                              balance_to_finish
                                                               ,
                                                        decode(to_char(nvl((ln_vw.quantity -(wcl.total_completed_to_date / ln_vw.list_price
                                                        )), 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char((ln_vw.quantity -(wcl.total_completed_to_date / ln_vw.list_price
                                                               )), 'FM999,999,999,999,999.00')) balance_to_finish_qty,
                                                        wcl.lot_no,
                                                        wcl.serial_no,
                                                        wcl.to_serial_no,
                                                        wcl.created_by,
                                                        wcl.created_on,
                                                        wcl.last_updated_by,
                                                        wcl.last_updated_on,
                                                        wcl.advance_invoice_number,
                                                        wcl.sub_inventory,
                                                        wch.retainage_perc                                                                                              retainage_rate
                                                        ,
                                                        ln_vw.line_num,
                                                        ln_vw.item_number,
                                                        ln_vw.shipment_num,
                                                        ln_vw.line_type_name,
                                                        ln_vw.line_status,
                                                        decode(to_char(nvl(ln_vw.list_price, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(ln_vw.list_price, 'FM999,999,999,999,999.00'))                                                   list_price
                                                               ,
                                                        decode(to_char(nvl(ln_vw.quantity * ln_vw.list_price, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(ln_vw.quantity * ln_vw.list_price, 'FM999,999,999,999,999.00')
                                                               )                                  total_price,
                                                        decode(to_char(nvl(ln_vw.quantity * ln_vw.list_price, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(ln_vw.quantity * ln_vw.list_price, 'FM999,999,999,999,999.00')
                                                               )                                  scheduled_value,
                                                        ln_vw.item_description,
                                                        decode(to_char(nvl(ln_vw.quantity, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(ln_vw.quantity, 'FM999,999,999,999,999.00'))                                                     quantity
                                                               ,
                                                        ln_vw.uom_code,
                                                        ln_vw.requester_id,
                                                        ln_vw.requisition_number,
                                                        ln_vw.requisition_header_id,
                                                        ln_vw.preparer_id,
                                                        ln_vw.lot_control_code,
                                                        ln_vw.serial_number_control_code,
                                                        ln_vw.lot_control,
                                                        ln_vw.serial_control,
                                                        ln_vw.item_organization_id
                                                    FROM
                                                        posext.xxarm_work_certificate_line wcl,
                                                        xxarm_work_cert_po_lines_v         ln_vw
                                                    WHERE
                                                            wcl.wc_certificate_id = wch.wc_certificate_id
                                                        AND wcl.po_line_id = ln_vw.po_line_id
                                                )                                                                            AS line_details
                                                ,
                                                CURSOR (
                                                    SELECT
                                                        *
                                                    FROM
                                                        posext.xxarm_po_documents_tab
                                                    WHERE
                                                            object_name = 'XXARM_WORK_CERTIFICATE_HDR'
                                                        AND object_id = wch.wc_certificate_id
                                                )                                                                            AS attachments
                                                ,
                                                CURSOR (
                                                    SELECT
                                                        doc_seq_key,
                                                        doc_id,
                                                        ln_vw.line_num document_category,
                                                        document_name,
                                                        mimetype,
                                                        document_link,
                                                        object_name,
                                                        object_id,
                                                        bu_name,
                                                        submitted_doc_type,
                                                        ln_vw.po_header_id,
                                                        business_identifier,
                                                        doc.creation_date,
                                                        doc.created_by,
                                                        doc.last_update_date,
                                                        doc.last_updated_by
                                                    FROM
                                                        posext.xxarm_po_documents_tab      doc,
                                                        posext.xxarm_work_certificate_line wcl,
                                                        xxarm_work_cert_po_lines_v         ln_vw
                                                    WHERE
                                                            object_name = 'XXARM_WORK_CERTIFICATE_LINE'
                                                        AND object_id = wcl.wc_certificate_line_id
                                                        AND wcl.wc_certificate_id = wch.wc_certificate_id
                                                        AND wcl.po_line_id = ln_vw.po_line_id
                                                )                                                                            AS wc_line_attachements
                                            FROM
                                                xxarm_work_cert_search_v wch
                            WHERE
                                    wch.wc_certificate_id = TO_NUMBER(p_bussiness_id)
                                AND ROWNUM = 1;
    --xxarm_work_certificate_opa_v;

        ELSIF p_process_name = 'ARMEXTN_FinanceSubmittalsApplication' THEN
            OPEN x_data FOR SELECT
                                                tsh.fs_id,
                                                tsh.po_header_id                     po_header_id,
                                                tsh.submittals_no                    fin_submittals_no,
                                                tsh.submittals_status,
                                                decode(tsh.comments, NULL, '', NULL) comments,
                                                tsh.created_by,
                                                tsh.creation_date,
                                                tsh.last_updated_by,
                                                tsh.last_updated_date,
                                                'Incomplete'                         approval_status,
                                                tsh.opa_instance_id,
                                                systimestamp                         opa_submitted_date,
                                                ' test '                             opa_submit_by,
                                                tsh.po_number                        purchase_order_number,
                                                'XXARM_FINANCE_SUBMITTALS_HDR'       tab_name,
                                                (
                                                    SELECT
                                                        houftl.name
                                                    FROM
                                                        armhcm.hr_organization_units_f_tl houftl
                                        --armscm.po_headers_all             pha
                                                    WHERE
                                                            houftl.organization_id = tsh.prc_bu_id
                                                        AND ROWNUM = 1
                                                )                                    sold_to_business_unit,
--                                (
--                                    SELECT
--                                        ppf.first_name
--                                        || ' '
--                                        || ppf.middle_names
--                                        || ' '
--                                        || ppf.last_name buyer_name
--                                    FROM
--                                        armhcm.per_person_names_f ppf
--                                    WHERE
--                                            ppf.person_id = pha.agent_id
--                                        AND trunc(sysdate) BETWEEN ppf.effective_start_date AND ppf.effective_end_date
--                                        AND ppf.name_type = 'GLOBAL'
--                                        AND ppf.char_set_context = 'US'
--                                        AND ROWNUM = 1
--                                )     
                                                tsh.buyer_name                       buyer_name,
                                                (
                                                    SELECT
                                                        party_name
                                                    FROM
                                                        armscm.poz_suppliers_all sup,
                                                        armerp.hz_parties        hp
                                                    WHERE
                                                            hp.party_id = sup.party_id
                                                        AND sup.vendor_id = tsh.vendor_id
                                                )                                    supplier_name,
                                                ' test_project '                     project_info,
                                                tsh.advance_payment_perc             advpmt_percent,
                                                tsh.retention_perc                   reten_percent,
                                                tsh.bank_guarantee_flag              bank_guarantee,
                                                'True' --tsh.performance_guarantee_flag 
                                                                               perf_guarantee,
                                --tsh.adv_pay_sec_cheque_flag
                                                'True'                               advpmt_chq,
                                                'attribute1'                         attribute1,
                                                'attribute1'                         attribute2,
                                                'attribute1'                         attribute3,
                                                'attribute1'                         attribute4,
                                                'attribute1'                         attribute5,
                                                'attribute1'                         attribute6,
                                                'attribute1'                         attribute7,
                                                'attribute1'                         attribute8,
                                                'attribute1'                         attribute9,
                                                'attribute1'                         attribute10,
                                                CURSOR (
                                                    SELECT
                                        --tsl.*,
                                                        decode(to_char(nvl(tsl.amount, 0),
                                                                       'FM999,999,999,999,999.00'),
                                                               '.00',
                                                               '0.00',
                                                               to_char(tsl.amount, 'FM999,999,999,999,999.00')) line_amount,
                                                        tsl.submittals_type                                     submittals,
                                                        tsl.purpose                                             submittals_purpose,
                                                        tsl.issuing_bank_name                                   issue_bank_name,
                                                        tsl.issuing_bank_address                                issue_bank_add,
                                                        tsl.guarantee_no                                        guarantee_no,
                                                        tsl.guarantee_type                                      guarantee_type,
                                                        tsl.original_guarantee_no                               org_guarantee_no,
                                                        tsl.cheque_no                                           cheque_no,
                                                        tsl.cheque_date                                         cheque_date,
                                                        tsl.valid_from,
                                                        tsl.valid_to,
                                                        'attribute1'                                            attribute1,
                                                        'attribute1'                                            attribute2,
                                                        'attribute1'                                            attribute3,
                                                        'attribute1'                                            attribute4,
                                                        'attribute1'                                            attribute5,
                                                        'attribute1'                                            attribute6,
                                                        'attribute1'                                            attribute7,
                                                        'attribute1'                                            attribute8,
                                                        'attribute1'                                            attribute9,
                                                        'attribute1'                                            attribute10,
                                                        CURSOR (
                                                            SELECT
                                                                doc_seq_key,
                                                                doc_id,
                                                                document_category,
                                                                document_name,
                                                                mimetype,
                                                                document_link,
                                                                object_name,
                                                                object_id,
                                                                bu_name,
                                                                submitted_doc_type,
                                                                po_header_id,
                                                                tsl.purpose business_identifier,
                                                                creation_date,
                                                                created_by,
                                                                last_update_date,
                                                                last_updated_by
                                                            FROM
                                                                posext.xxarm_po_documents_tab
                                                            WHERE
                                                                    object_name = 'XXARM_FINANCE_SUBMITTALS_LINES'
                                                                AND object_id = tsl.fs_line_id
                                                        )                                                       AS line_attachements
                                                    FROM
                                                        posext.xxarm_fin_submittals_line_tab tsl
                                                    WHERE
                                                        fs_id = tsh.fs_id
                                                )                                    lines_data,
                                                CURSOR (
                                                    SELECT
                                                        doc_seq_key,
                                                        doc_id,
                                                        document_category,
                                                        document_name,
                                                        mimetype,
                                                        document_link,
                                                        object_name,
                                                        object_id,
                                                        bu_name,
                                                        submitted_doc_type,
                                                        po_header_id,
                                                        business_identifier,
                                                        creation_date,
                                                        created_by,
                                                        last_update_date,
                                                        last_updated_by
                                                    FROM
                                                        posext.xxarm_po_documents_tab
                                                    WHERE
                                                            object_name = 'XXARM_FINANCE_SUBMITTALS_HDR'
                                                        AND object_id = tsh.fs_id
                                                )                                    AS ts_hdr_attachments
                                            FROM
                                                xxarm_fin_submittals_search_v tsh
                            WHERE
                                    tsh.fs_id = TO_NUMBER(p_bussiness_id)
--                                AND pha.po_header_id = tsh.po_header_id
                                AND ROWNUM = 1;

        END IF;

    EXCEPTION
        WHEN OTHERS THEN
            x_return_code := 'MAIN EXCEPTION ERROR';
            x_return_message := x_return_message
                                || '  '
                                || '[APPERR05] Error Others: '
                                || sqlerrm
                                || ' - '
                                || dbms_utility.format_error_backtrace;

    END get_approval_data;

END xxarm_cmn_opa_approval_pkg;