-- Versão simples: apenas inserir cursos e criar política RLS

-- Inserir cursos de teste
INSERT INTO courses (name, semester, period, coordinator, duration, description) 
VALUES 
  ('Engenharia de Software', 1, 'Matutino', 'Prof. João Silva', 8, 'Curso de Engenharia de Software'),
  ('Ciência da Computação', 1, 'Noturno', 'Prof. Maria Santos', 8, 'Curso de Ciência da Computação'),
  ('Sistemas de Informação', 1, 'Matutino', 'Prof. Carlos Lima', 8, 'Curso de Sistemas de Informação');

-- Criar política RLS para permitir leitura pública
DROP POLICY IF EXISTS "Permitir leitura pública de cursos" ON courses;
CREATE POLICY "Permitir leitura pública de cursos" ON courses FOR SELECT USING (true); 