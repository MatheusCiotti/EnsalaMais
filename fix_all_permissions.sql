-- Script completo para corrigir políticas RLS de todas as tabelas

-- ===== TABELA COURSES =====
DROP POLICY IF EXISTS "Permitir leitura pública de cursos" ON courses;
CREATE POLICY "Permitir leitura pública de cursos" ON courses FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de cursos" ON courses FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de cursos" ON courses FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de cursos" ON courses FOR DELETE USING (true);

-- ===== TABELA ROOMS =====
DROP POLICY IF EXISTS "Permitir leitura de rooms" ON rooms;
DROP POLICY IF EXISTS "Permitir inserção de rooms" ON rooms;
DROP POLICY IF EXISTS "Permitir atualização de rooms" ON rooms;
DROP POLICY IF EXISTS "Permitir exclusão de rooms" ON rooms;

CREATE POLICY "Permitir leitura de rooms" ON rooms FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de rooms" ON rooms FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de rooms" ON rooms FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de rooms" ON rooms FOR DELETE USING (true);

-- ===== TABELA CLASSES =====
DROP POLICY IF EXISTS "Permitir leitura de classes" ON classes;
DROP POLICY IF EXISTS "Permitir inserção de classes" ON classes;
DROP POLICY IF EXISTS "Permitir atualização de classes" ON classes;
DROP POLICY IF EXISTS "Permitir exclusão de classes" ON classes;

CREATE POLICY "Permitir leitura de classes" ON classes FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de classes" ON classes FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de classes" ON classes FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de classes" ON classes FOR DELETE USING (true);

-- ===== TABELA COURSE_CLASSES =====
DROP POLICY IF EXISTS "Permitir leitura de course_classes" ON course_classes;
DROP POLICY IF EXISTS "Permitir inserção de course_classes" ON course_classes;
DROP POLICY IF EXISTS "Permitir atualização de course_classes" ON course_classes;
DROP POLICY IF EXISTS "Permitir exclusão de course_classes" ON course_classes;

CREATE POLICY "Permitir leitura de course_classes" ON course_classes FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de course_classes" ON course_classes FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de course_classes" ON course_classes FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de course_classes" ON course_classes FOR DELETE USING (true);

-- ===== TABELA BLOCKS =====
DROP POLICY IF EXISTS "Permitir leitura de blocks" ON blocks;
DROP POLICY IF EXISTS "Permitir inserção de blocks" ON blocks;
DROP POLICY IF EXISTS "Permitir atualização de blocks" ON blocks;
DROP POLICY IF EXISTS "Permitir exclusão de blocks" ON blocks;

CREATE POLICY "Permitir leitura de blocks" ON blocks FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de blocks" ON blocks FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de blocks" ON blocks FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de blocks" ON blocks FOR DELETE USING (true);

-- ===== TABELA ENSALAMENTOS =====
DROP POLICY IF EXISTS "Permitir leitura de ensalamentos" ON ensalamentos;
DROP POLICY IF EXISTS "Permitir inserção de ensalamentos" ON ensalamentos;
DROP POLICY IF EXISTS "Permitir atualização de ensalamentos" ON ensalamentos;
DROP POLICY IF EXISTS "Permitir exclusão de ensalamentos" ON ensalamentos;

CREATE POLICY "Permitir leitura de ensalamentos" ON ensalamentos FOR SELECT USING (true);
CREATE POLICY "Permitir inserção de ensalamentos" ON ensalamentos FOR INSERT WITH CHECK (true);
CREATE POLICY "Permitir atualização de ensalamentos" ON ensalamentos FOR UPDATE USING (true) WITH CHECK (true);
CREATE POLICY "Permitir exclusão de ensalamentos" ON ensalamentos FOR DELETE USING (true);

-- ===== VERIFICAÇÃO FINAL =====
SELECT 'Verificação final das políticas:' as debug_step;
SELECT tablename, policyname, cmd FROM pg_policies 
WHERE tablename IN ('courses', 'rooms', 'classes', 'course_classes', 'blocks', 'ensalamentos')
ORDER BY tablename, cmd; 