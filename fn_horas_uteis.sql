DELIMITER $$
CREATE FUNCTION `fn_horas_uteis`(param_id_calendario INT, param_dt_ini DATETIME, param_dt_fim DATETIME) RETURNS time
    DETERMINISTIC
BEGIN

    DECLARE var_i INT DEFAULT 0;
    DECLARE var_dias_semana INT;
    DECLARE var_total_horas TIME;
    DECLARE var_qtde_dias INT;
    DECLARE var_dia_horas TIME;
  
    DECLARE var_inicio_jornada TIME;
    DECLARE var_fim_jornada TIME;
    DECLARE var_dia_atual DATE;
  
    DECLARE var_ini_almoco_jornada TIME;
    DECLARE var_fim_almoco_jornada TIME;
  
    DECLARE var_ini_almoco_jornada_param_dt_ini TIME;
    DECLARE var_fim_almoco_jornada_param_dt_ini TIME;
  
    DECLARE var_horas_para_somar TIME;
    DECLARE var_prazo TIME DEFAULT '838:59:59';
    DECLARE var_ini_feriado TIME;
    DECLARE var_fim_feriado TIME;
    DECLARE var_horas_feriado TIME;
    DECLARE var_horas_almoco TIME;
    DECLARE var_hora_inicio TIME;
    DECLARE var_hora_fim TIME;
    DECLARE var_horas_dia TIME;
  
    # Luan Gregati 07/01/2015 Validação de Parâmetros
    IF (param_id_calendario IS NULL OR
      param_id_calendario = 0 OR
      param_dt_ini IS NULL OR
      param_dt_ini = '00:00:00' OR
          param_dt_fim IS NULL OR
          param_dt_fim = '00:00:00') THEN
      RETURN '00:00:00';
    END IF;
  
    SET var_total_horas = '00:00:00';
    SET var_dia_horas = '00:00:00';
    SET var_qtde_dias = (SELECT DATEDIFF(param_dt_fim, param_dt_ini) + 1);
  
    myloop: WHILE var_i < var_qtde_dias DO
  
      SET var_fim_jornada = NULL;
  
      SET var_dia_atual = DATE_ADD(DATE(param_dt_ini), INTERVAL var_i DAY);
  
      SET var_dias_semana = DAYOFWEEK(var_dia_atual);
  
      SET var_ini_feriado = NULL;
  
      SET var_fim_feriado = NULL;
  
      SET var_horas_feriado = NULL;
  
      SET var_horas_almoco = NULL;
  
      IF (var_inicio_jornada IS NULL) THEN
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_inicio
                  WHEN var_dias_semana = 2 THEN seg_manha_inicio
                  WHEN var_dias_semana = 3 THEN ter_manha_inicio
                  WHEN var_dias_semana = 4 THEN qua_manha_inicio
                  WHEN var_dias_semana = 5 THEN qui_manha_inicio
                  WHEN var_dias_semana = 6 THEN sex_manha_inicio
                  WHEN var_dias_semana = 7 THEN sab_manha_inicio
              END) INTO var_inicio_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_fim
                  WHEN var_dias_semana = 2 THEN seg_manha_fim
                  WHEN var_dias_semana = 3 THEN ter_manha_fim
                  WHEN var_dias_semana = 4 THEN qua_manha_fim
                  WHEN var_dias_semana = 5 THEN qui_manha_fim
                  WHEN var_dias_semana = 6 THEN sex_manha_fim
                  WHEN var_dias_semana = 7 THEN sab_manha_fim
              END) INTO var_ini_almoco_jornada_param_dt_ini FROM calendario_trabalho WHERE id = param_id_calendario;
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_inicio
                  WHEN var_dias_semana = 2 THEN seg_tarde_inicio
                  WHEN var_dias_semana = 3 THEN ter_tarde_inicio
                  WHEN var_dias_semana = 4 THEN qua_tarde_inicio
                  WHEN var_dias_semana = 5 THEN qui_tarde_inicio
                  WHEN var_dias_semana = 6 THEN sex_tarde_inicio
                  WHEN var_dias_semana = 7 THEN sab_tarde_inicio
              END) INTO var_fim_almoco_jornada_param_dt_ini FROM calendario_trabalho WHERE id = param_id_calendario;
  
      END IF;
  
        IF (var_inicio_jornada IS NULL) THEN
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_inicio
                  WHEN var_dias_semana = 2 THEN seg_tarde_inicio
                  WHEN var_dias_semana = 3 THEN ter_tarde_inicio
                  WHEN var_dias_semana = 4 THEN qua_tarde_inicio
                  WHEN var_dias_semana = 5 THEN qui_tarde_inicio
                  WHEN var_dias_semana = 6 THEN sex_tarde_inicio
                  WHEN var_dias_semana = 7 THEN sab_tarde_inicio
              END) INTO var_inicio_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_fim
                  WHEN var_dias_semana = 2 THEN seg_manha_fim
                  WHEN var_dias_semana = 3 THEN ter_manha_fim
                  WHEN var_dias_semana = 4 THEN qua_manha_fim
                  WHEN var_dias_semana = 5 THEN qui_manha_fim
                  WHEN var_dias_semana = 6 THEN sex_manha_fim
                  WHEN var_dias_semana = 7 THEN sab_manha_fim
              END) INTO var_ini_almoco_jornada_param_dt_ini FROM calendario_trabalho WHERE id = param_id_calendario;
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_inicio
                  WHEN var_dias_semana = 2 THEN seg_tarde_inicio
                  WHEN var_dias_semana = 3 THEN ter_tarde_inicio
                  WHEN var_dias_semana = 4 THEN qua_tarde_inicio
                  WHEN var_dias_semana = 5 THEN qui_tarde_inicio
                  WHEN var_dias_semana = 6 THEN sex_tarde_inicio
                  WHEN var_dias_semana = 7 THEN sab_tarde_inicio
              END) INTO var_fim_almoco_jornada_param_dt_ini FROM calendario_trabalho WHERE id = param_id_calendario;
  
        END IF;
  
        IF (var_fim_jornada IS NULL) THEN
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_fim
                  WHEN var_dias_semana = 2 THEN seg_tarde_fim
                  WHEN var_dias_semana = 3 THEN ter_tarde_fim
                  WHEN var_dias_semana = 4 THEN qua_tarde_fim
                  WHEN var_dias_semana = 5 THEN qui_tarde_fim
                  WHEN var_dias_semana = 6 THEN sex_tarde_fim
                  WHEN var_dias_semana = 7 THEN sab_tarde_fim
              END) INTO var_fim_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
        END IF;
  
              IF (var_fim_jornada IS NULL) THEN
  
          SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_fim
                  WHEN var_dias_semana = 2 THEN seg_manha_fim
                  WHEN var_dias_semana = 3 THEN ter_manha_fim
                  WHEN var_dias_semana = 4 THEN qua_manha_fim
                  WHEN var_dias_semana = 5 THEN qui_manha_fim
                  WHEN var_dias_semana = 6 THEN sex_manha_fim
                  WHEN var_dias_semana = 7 THEN sab_manha_fim
              END) INTO var_fim_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
        END IF;
  
        -- CALCULANDO HORÁRIO DE ALMOÇO PARA O PERÍODO FINAL
              SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_inicio
                  WHEN var_dias_semana = 2 THEN seg_tarde_inicio
                  WHEN var_dias_semana = 3 THEN ter_tarde_inicio
                  WHEN var_dias_semana = 4 THEN qua_tarde_inicio
                  WHEN var_dias_semana = 5 THEN qui_tarde_inicio
                  WHEN var_dias_semana = 6 THEN sex_tarde_inicio
                  WHEN var_dias_semana = 7 THEN sab_tarde_inicio
              END) INTO var_fim_almoco_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
              SELECT (CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_fim
                  WHEN var_dias_semana = 2 THEN seg_manha_fim
                  WHEN var_dias_semana = 3 THEN ter_manha_fim
                  WHEN var_dias_semana = 4 THEN qua_manha_fim
                  WHEN var_dias_semana = 5 THEN qui_manha_fim
                  WHEN var_dias_semana = 6 THEN sex_manha_fim
                  WHEN var_dias_semana = 7 THEN sab_manha_fim
              END) INTO var_ini_almoco_jornada FROM calendario_trabalho WHERE id = param_id_calendario;
  
              IF (var_inicio_jornada IS NULL) THEN
          SET var_inicio_jornada = '00:00:59';
        END IF;
  
        -- CALCULANDO HORAS CASO SEJA FERIADO
          SELECT  
              hora_inicio,
              hora_fim
              INTO var_ini_feriado, var_fim_feriado
          FROM
              feriado f
          INNER JOIN feriado_calendario_trabalho fct ON f.id = fct.feriado_id
          WHERE f.excluido = 'N' AND f.data_feriado = var_dia_atual AND fct.calendario_trabalho_id = param_id_calendario;
          
          -- CALCULANDO HORAS UTEIS DO DIA
          SET var_horas_para_somar = SEC_TO_TIME((SELECT ((COALESCE(TIME_TO_SEC(CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_fim
                  WHEN var_dias_semana = 2 THEN seg_manha_fim
                  WHEN var_dias_semana = 3 THEN ter_manha_fim
                  WHEN var_dias_semana = 4 THEN qua_manha_fim
                  WHEN var_dias_semana = 5 THEN qui_manha_fim
                  WHEN var_dias_semana = 6 THEN sex_manha_fim
                  WHEN var_dias_semana = 7 THEN sab_manha_fim
              END), 0) - COALESCE(TIME_TO_SEC(CASE 
                  WHEN var_dias_semana = 1 THEN dom_manha_inicio
                  WHEN var_dias_semana = 2 THEN seg_manha_inicio
                  WHEN var_dias_semana = 3 THEN ter_manha_inicio
                  WHEN var_dias_semana = 4 THEN qua_manha_inicio
                  WHEN var_dias_semana = 5 THEN qui_manha_inicio
                  WHEN var_dias_semana = 6 THEN sex_manha_inicio
                  WHEN var_dias_semana = 7 THEN sab_manha_inicio
              END), 0)) + (COALESCE(TIME_TO_SEC(CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_fim
                  WHEN var_dias_semana = 2 THEN seg_tarde_fim
                  WHEN var_dias_semana = 3 THEN ter_tarde_fim
                  WHEN var_dias_semana = 4 THEN qua_tarde_fim
                  WHEN var_dias_semana = 5 THEN qui_tarde_fim
                  WHEN var_dias_semana = 6 THEN sex_tarde_fim
                  WHEN var_dias_semana = 7 THEN sab_tarde_fim
              END), 0) - COALESCE(TIME_TO_SEC(CASE 
                  WHEN var_dias_semana = 1 THEN dom_tarde_inicio
                  WHEN var_dias_semana = 2 THEN seg_tarde_inicio
                  WHEN var_dias_semana = 3 THEN ter_tarde_inicio
                  WHEN var_dias_semana = 4 THEN qua_tarde_inicio
                  WHEN var_dias_semana = 5 THEN qui_tarde_inicio
                  WHEN var_dias_semana = 6 THEN sex_tarde_inicio
                  WHEN var_dias_semana = 7 THEN sab_tarde_inicio
              END), 0)))  FROM calendario_trabalho WHERE id = param_id_calendario));
          
          SELECT COALESCE (SEC_TO_TIME(TIME_TO_SEC(var_fim_almoco_jornada) - TIME_TO_SEC(var_ini_almoco_jornada)), TIME(0)) INTO var_horas_almoco;
  
          IF (var_horas_para_somar <= (var_prazo - var_total_horas)) THEN
          
              SET var_dia_horas = SEC_TO_TIME(TIME_TO_SEC(var_total_horas) + TIME_TO_SEC(var_horas_para_somar));
  
              IF (var_ini_feriado IS NOT NULL AND var_fim_feriado IS NOT NULL) THEN
                  IF (var_ini_feriado < var_inicio_jornada) THEN
                      SET var_ini_feriado = var_inicio_jornada;
                  END IF;
  
                  IF (var_fim_feriado > var_fim_jornada) THEN
                      SET var_fim_feriado = var_fim_jornada;
                  END IF;
  
                  IF (var_dia_atual = DATE(param_dt_ini) AND TIME(param_dt_ini) > var_fim_feriado) THEN
                      SET var_fim_feriado = TIME(param_dt_ini);
                  END IF;
  
                  IF (var_ini_feriado BETWEEN var_ini_almoco_jornada AND var_fim_almoco_jornada) THEN
                      SET var_ini_feriado = var_fim_almoco_jornada;
                  END IF;
  
                  IF (var_fim_feriado BETWEEN var_ini_almoco_jornada AND var_fim_almoco_jornada) THEN
                      SET var_fim_feriado = var_fim_almoco_jornada;
                  END IF;
  
                  SELECT (SEC_TO_TIME(TIME_TO_SEC(var_fim_feriado) - TIME_TO_SEC(var_ini_feriado) - TIME_TO_SEC(var_horas_almoco))) INTO var_horas_feriado;
  
                  IF (SEC_TO_TIME(var_horas_feriado) < 0) THEN
                      SET var_horas_feriado = TIME(0);
                  END IF;
                  
                  IF (SEC_TO_TIME(var_horas_feriado) > SEC_TO_TIME(var_horas_para_somar)) THEN
                      SET var_horas_feriado = var_horas_para_somar;
                  END IF;                
                  
                  SET var_total_horas = SEC_TO_TIME(TIME_TO_SEC(var_total_horas) + (TIME_TO_SEC(var_horas_para_somar) - TIME_TO_SEC(var_horas_feriado)));
              ELSE
  
                  IF (var_dia_atual = DATE(param_dt_ini) AND TIME(param_dt_ini) >= var_inicio_jornada) THEN
                      SET var_hora_inicio = TIME(param_dt_ini);
                  ELSE
                      SET var_hora_inicio = var_inicio_jornada;
                  END IF;
  
                  IF (var_dia_atual = DATE(param_dt_fim) AND TIME(param_dt_fim) <= var_fim_jornada) THEN
                      SET var_hora_fim = TIME(param_dt_fim);
                  ELSE
                      SET var_hora_fim = var_fim_jornada;
                  END IF;
  
                  IF (var_hora_inicio BETWEEN var_ini_almoco_jornada AND var_fim_almoco_jornada) THEN
                      SET var_horas_almoco = TIME(0); /* zero as hoas de almoço pois o inicio da jornada é após o término do almoço */
                      SET var_hora_inicio = var_fim_almoco_jornada;
                  END IF;
  
                  IF (var_hora_fim BETWEEN var_ini_almoco_jornada AND var_fim_almoco_jornada) THEN
                      SET var_hora_fim = var_fim_almoco_jornada;
                  END IF;
  
                  IF ((TIME(param_dt_ini) > var_fim_almoco_jornada AND var_dia_atual = DATE(param_dt_ini)) OR (TIME(param_dt_fim) < var_ini_almoco_jornada AND var_dia_atual = DATE(param_dt_fim))) THEN
                      SET var_horas_almoco = TIME(0);
                  END IF;
                  
                  SET var_horas_dia = SEC_TO_TIME((COALESCE(TIME_TO_SEC(var_hora_fim), 0) - COALESCE(TIME_TO_SEC(var_hora_inicio), 0)) - COALESCE(TIME_TO_SEC(var_horas_almoco), 0));
  
                  IF(var_horas_dia < 0) THEN
                      SET var_horas_dia = 0;
                  END IF;
  
                  SET var_total_horas = SEC_TO_TIME(TIME_TO_SEC(var_total_horas) + TIME_TO_SEC(var_horas_dia));
  
              END IF;
          ELSE
              SET var_total_horas = var_prazo;
          END IF;
  
      IF (var_total_horas = var_prazo) THEN
        LEAVE myloop;
      END IF;
  
      SET var_i = var_i + 1;
  
    END WHILE;
  
      IF (var_total_horas IS NULL OR SEC_TO_TIME(var_total_horas) < 0) THEN
          RETURN TIME(0);
      ELSE
          RETURN var_total_horas;
      END IF;
  
  END$$
DELIMITER ;
