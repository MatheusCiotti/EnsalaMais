-- Script para inserir cursos de teste no banco de dados

-- 1. Verificar se existem dados na tabela courses
SELECT 'Verificando dados existentes na tabela courses:' as debug_step;
SELECT * FROM courses;

-- 2. Inserir dados de teste (sem ON CONFLICT)
INSERT INTO courses (name, semester, period, coordinator, duration, description) 
VALUES 
  ('Engenharia de Software', 1, 'Matutino', 'Prof. João Silva', 8, 'Curso de Engenharia de Software'),
  ('Ciência da Computação', 1, 'Noturno', 'Prof. Maria Santos', 8, 'Curso de Ciência da Computação'),
  ('Sistemas de Informação', 1, 'Matutino', 'Prof. Carlos Lima', 8, 'Curso de Sistemas de Informação'),
  ('Engenharia Civil', 1, 'Matutino', 'Prof. Ana Costa', 10, 'Curso de Engenharia Civil'),
  ('Administração', 1, 'Noturno', 'Prof. Pedro Oliveira', 8, 'Curso de Administração');

-- 3. Verificar se RLS está habilitado e criar política se necessário
SELECT 'Verificando políticas RLS:' as debug_step;
SELECT schemaname, tablename, policyname, permissive, roles, cmd, qual, with_check 
FROM pg_policies 
WHERE tablename = 'courses';

-- 4. Criar política RLS para permitir leitura pública dos cursos
DROP POLICY IF EXISTS "Permitir leitura pública de cursos" ON courses;
CREATE POLICY "Permitir leitura pública de cursos" ON courses
  FOR SELECT USING (true);

-- 5. Verificar os dados após inserção
SELECT 'Dados após inserção:' as debug_step;
SELECT id, name, semester, period, coordinator FROM courses ORDER BY name; 