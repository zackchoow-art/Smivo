allprojects {
    repositories {
        google()
        mavenCentral()
    }
}

val newBuildDir: Directory = rootProject.layout.buildDirectory.dir("../../build").get()
rootProject.layout.buildDirectory.value(newBuildDir)

subprojects {
    val newSubprojectBuildDir: Directory = newBuildDir.dir(project.name)
    project.layout.buildDirectory.value(newSubprojectBuildDir)
}
subprojects {
    project.evaluationDependsOn(":app")
}

subprojects {
    plugins.withId("com.android.library") {
        val androidComponents = project.extensions.findByName("androidComponents")
        if (androidComponents != null) {
            try {
                val finalizeDslMethod = androidComponents.javaClass.getMethod("finalizeDsl", org.gradle.api.Action::class.java)
                val action = object : org.gradle.api.Action<Any> {
                    override fun execute(extension: Any) {
                        try {
                            val getCompileSdk = extension.javaClass.getMethod("getCompileSdk")
                            val currentCompileSdk = getCompileSdk.invoke(extension) as? java.lang.Integer
                            if (currentCompileSdk == null || currentCompileSdk.toInt() < 34) {
                                val setCompileSdk = extension.javaClass.getMethod("setCompileSdk", java.lang.Integer::class.java)
                                setCompileSdk.invoke(extension, 34)
                                println("Antigravity: upgraded compileSdk from ${currentCompileSdk} to 34 for subproject ${project.name}")
                            } else {
                                println("Antigravity: kept compileSdk at ${currentCompileSdk} for subproject ${project.name}")
                            }
                        } catch (e: Exception) {
                            // Ignore
                        }
                        try {
                            val defaultConfig = extension.javaClass.getMethod("getDefaultConfig").invoke(extension)
                            val getTargetSdk = defaultConfig.javaClass.getMethod("getTargetSdk")
                            val currentTargetSdk = getTargetSdk.invoke(defaultConfig) as? java.lang.Integer
                            if (currentTargetSdk == null || currentTargetSdk.toInt() < 34) {
                                val setTargetSdk = defaultConfig.javaClass.getMethod("setTargetSdk", java.lang.Integer::class.java)
                                setTargetSdk.invoke(defaultConfig, 34)
                                println("Antigravity: upgraded targetSdk from ${currentTargetSdk} to 34 for subproject ${project.name}")
                            } else {
                                println("Antigravity: kept targetSdk at ${currentTargetSdk} for subproject ${project.name}")
                            }
                        } catch (e: Exception) {
                            // Ignore
                        }
                    }
                }
                finalizeDslMethod.invoke(androidComponents, action)
            } catch (e: Exception) {
                // Ignore
            }
        }
    }

    val fixNamespace = {
        if (project.extensions.findByName("android") != null) {
            val android = project.extensions.getByName("android") as com.android.build.gradle.BaseExtension
            if (android.namespace == null) {
                android.namespace = "com.smivo.plugins.${project.name.replace("-", ".")}"
            }
            
            // NEW: Strip package attribute from Manifest to satisfy AGP 8.0+
            val manifestFile = project.file("src/main/AndroidManifest.xml")
            if (manifestFile.exists()) {
                val content = manifestFile.readText()
                if (content.contains("package=")) {
                    val newContent = content.replace(Regex("package=\"[^\"]*\""), "")
                    manifestFile.writeText(newContent)
                }
            }
        }
    }

    if (project.state.executed) {
        fixNamespace()
    } else {
        project.afterEvaluate { fixNamespace() }
    }
}

tasks.register<Delete>("clean") {
    delete(rootProject.layout.buildDirectory)
}
